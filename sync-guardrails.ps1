# sync-guardrails.ps1 — ガードレール配布スクリプト
#
# dev_setting をマスターとして、各プロジェクトにルール・コマンド・テンプレートを配布する。
# 配布するのはガードレール（CLAUDE.md / AGENTS.md、コマンド/スキル、_TEMPLATE類）のみ。
# 各プロジェクトの実文書（requirements.md、チケット、ADR等）には絶対に触れない。
#
# 使い方:
#   .\sync-guardrails.ps1                                # projects.txt の全プロジェクトへ同期
#   .\sync-guardrails.ps1 -DryRun                        # 何がコピーされるか確認のみ
#   .\sync-guardrails.ps1 -Init C:\path\to\new-project   # 新規プロジェクトを初期化して登録
#   .\sync-guardrails.ps1 -Init C:\path -Type claude     # Claude Code用のみ（既定は both）

param(
  [string]$Init,
  [ValidateSet('claude', 'codex', 'both')][string]$Type = 'both',
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$master = $PSScriptRoot
$projectsFile = Join-Path $master 'projects.txt'

function Copy-GuardFile($src, $dst, [switch]$SkipIfExists) {
  if (-not (Test-Path $src)) { Write-Warning "マスターに存在しません: $src"; return }
  if ($SkipIfExists -and (Test-Path $dst)) { return }
  $dir = Split-Path $dst -Parent
  if (-not (Test-Path $dir)) {
    if (-not $DryRun) { New-Item -ItemType Directory -Force $dir | Out-Null }
  }
  if ($DryRun) { Write-Host "  [dry] $dst" }
  else { Copy-Item $src $dst -Force; Write-Host "  -> $dst" }
}

# docs のテンプレート類を配布（生きた文書・実文書には触れない）
function Sync-DocsTemplates($srcRoot, $proj) {
  $templates = @(
    'docs\requirements\_TEMPLATE.md',
    'docs\plans\_TEMPLATE.md',
    'docs\interfaces\_TEMPLATE-API.md',
    'docs\interfaces\_TEMPLATE-DB.md',
    'docs\designs\_TEMPLATE.md',
    'docs\tickets\_TEMPLATE.md',
    'docs\reviews\_TEMPLATE.md',
    'docs\adr\_TEMPLATE.md'
  )
  foreach ($rel in $templates) {
    Copy-GuardFile (Join-Path $srcRoot $rel) (Join-Path $proj $rel)
  }
  # TWEAKS.md は生きたログなので「無ければ雛形を置く」のみ。上書き禁止。
  Copy-GuardFile (Join-Path $srcRoot 'docs\TWEAKS.md') (Join-Path $proj 'docs\TWEAKS.md') -SkipIfExists
}

function Sync-Claude($proj) {
  Write-Host " [claude] $proj"
  Copy-GuardFile (Join-Path $master 'CLAUDE.md') (Join-Path $proj 'CLAUDE.md')
  # README.md はプロジェクト自身のREADMEと衝突するため GUARDRAILS.md として配布
  Copy-GuardFile (Join-Path $master 'README.md') (Join-Path $proj 'GUARDRAILS.md')
  Copy-GuardFile (Join-Path $master '.claude\settings.json') (Join-Path $proj '.claude\settings.json')
  Get-ChildItem (Join-Path $master '.claude\commands') -Filter *.md |
    Where-Object Name -ne 'spec-new.md' |    # 廃止コマンドは新規配布しない
    ForEach-Object { Copy-GuardFile $_.FullName (Join-Path $proj ".claude\commands\$($_.Name)") }
  Sync-DocsTemplates $master $proj
}

function Sync-Codex($proj) {
  Write-Host " [codex] $proj"
  $cm = Join-Path $master 'codex'
  Copy-GuardFile (Join-Path $cm 'AGENTS.md') (Join-Path $proj 'AGENTS.md')
  # README.md はプロジェクト自身のREADMEと衝突するため GUARDRAILS-codex.md として配布
  Copy-GuardFile (Join-Path $cm 'README.md') (Join-Path $proj 'GUARDRAILS-codex.md')
  Get-ChildItem (Join-Path $cm '.agents\skills') -Directory |
    Where-Object Name -ne 'spec-new' |       # 廃止スキルは新規配布しない
    ForEach-Object { Copy-GuardFile (Join-Path $_.FullName 'SKILL.md') (Join-Path $proj ".agents\skills\$($_.Name)\SKILL.md") }
  Sync-DocsTemplates $cm $proj
}

function Sync-Project($proj, $projType, [switch]$SkipExistCheck) {
  if (-not $SkipExistCheck -and -not (Test-Path $proj)) {
    Write-Warning "プロジェクトが見つかりません（スキップ）: $proj"; return
  }
  if ($projType -in @('claude', 'both')) { Sync-Claude $proj }
  if ($projType -in @('codex', 'both'))  { Sync-Codex  $proj }
}

if ($Init) {
  # 新規プロジェクトの初期化: docs構成を作成 → ガードレール配布 → projects.txt に登録
  $proj = $Init
  $dirs = @(
    'docs\requirements\archive', 'docs\plans', 'docs\interfaces\archive',
    'docs\designs', 'docs\tickets', 'docs\reviews', 'docs\adr'
  )
  foreach ($d in $dirs) {
    if (-not $DryRun) { New-Item -ItemType Directory -Force (Join-Path $proj $d) | Out-Null }
  }
  Write-Host "初期化: $proj (type: $Type)"
  Sync-Project $proj $Type -SkipExistCheck

  $entry = "$proj | $Type"
  $existing = @()
  if (Test-Path $projectsFile) { $existing = Get-Content $projectsFile }
  if ($existing -notcontains $entry -and -not $DryRun) {
    Add-Content $projectsFile $entry
    Write-Host "projects.txt に登録: $entry"
  }
  Write-Host "`n完了。次: プロジェクトを git init し、要件定義（/req-new）から開始してください。"
}
else {
  # 登録済み全プロジェクトへ同期
  if (-not (Test-Path $projectsFile)) {
    Write-Warning "projects.txt がありません。まず -Init で登録してください。"; exit 1
  }
  $lines = Get-Content $projectsFile | Where-Object { $_.Trim() -and -not $_.Trim().StartsWith('#') }
  if (-not $lines) { Write-Warning 'projects.txt に登録がありません。'; exit 0 }
  foreach ($line in $lines) {
    $parts = $line -split '\|' | ForEach-Object { $_.Trim() }
    $projType = if ($parts.Count -ge 2) { $parts[1] } else { 'both' }
    Sync-Project $parts[0] $projType
  }
  Write-Host "`n同期完了。"
}
