# ADR付きチケット駆動ATDD — Codex CLI向けセット（2層＋外部IF常設）

OpenAI Codex CLIで「要件定義 → 計画 → 1チケット＝1機能のATDD」を文書駆動で行うための
ガードレール一式。実プロジェクトにこのフォルダの中身をコピーして使う。

## 文書構成の考え方

個人＋AI開発で文書メンテが破綻しないよう、文書は3種類に分ける。

| 層 | 文書 | 作るタイミング |
|---|---|---|
| **背骨（常に作る）** | 要件定義書 → 計画書 → チケット → ADR・レビュー記録 | すべての開発で |
| **外部IF仕様書（常設）** | `docs/interfaces/API.md` / `DB.md` | 生きた文書として常時維持。変更は計画書＋ADR経由のみ |
| **任意層** | 詳細設計書（DESIGN-NN） | 複雑な機能・共通基盤などトリガー該当時のみ |

※ 旧「仕様書・基本設計書（SPEC）」層は2026-07-07に廃止（計画書・interfaces に役割を移管）。

## 構成（Claude Code版との対応）

| ファイル | 役割 | Claude Code版の対応物 |
|---|---|---|
| `AGENTS.md` | AIが毎セッション読むルール | `CLAUDE.md` |
| `.agents/skills/*/SKILL.md` | ワークフローを定型化するスキル | `.claude/commands/*.md` |
| `docs/requirements/_TEMPLATE.md` | 要件定義書（生きた文書） | 同一 |
| `docs/plans/_TEMPLATE.md` | 実装計画書（plan.mdの保存先） | 同一 |
| `docs/interfaces/_TEMPLATE-API.md` / `-DB.md` | 常設の外部IF仕様書 | 同一 |
| `docs/designs/_TEMPLATE.md` | 詳細設計書（任意層） | 同一 |
| `docs/tickets/_TEMPLATE.md` | チケットテンプレート | 同一 |
| `docs/reviews/_TEMPLATE.md` | レビュー記録テンプレート | 同一 |
| `docs/adr/_TEMPLATE.md` | ADRテンプレート | 同一 |
| `config.toml.sample` | 承認ポリシー・サンドボックス設定 | `.claude/settings.json` |

## セットアップ

1. このフォルダの中身（`config.toml.sample` 以外）をプロジェクトのルートにコピーする。
   - `AGENTS.md` はリポジトリルートに置く。
   - スキルは `.agents/skills/<name>/SKILL.md`。Codexが自動検出する。
2. `config.toml.sample` の内容を `~/.codex/config.toml` に反映する（グローバル設定）。

## 全体フロー

スキルは自然言語で呼び出せる（名前を明示してもよい）。

```
「〜を作りたい。要件定義から始めて」（req-new）
  → 要件定義書を作成 → 壁打ちでブラッシュアップ（決定の経緯は変更履歴に残る）→ 承認
「実装計画を立てて」（plan-new）
  → 実装計画書: アーキテクチャ・開発順序・規則・チケット分割 → 承認
    （プランモード / plan.md の計画はここに保存。外部IF影響も判定）
  → チケットごとにATDDの5フェーズ（下記）

（開発中に修正が出たら）
「〜が発覚した。計画書を作って」（plan-new, type: fix）
  → PLAN作成 → 承認 → 上流文書を更新 → 修正チケット化

（複雑な機能だけ）
「詳細設計を書いて」（design-new）  ← トリガー該当時のみ

（文言・レイアウト等の軽微修正だけ）
「〜の文言を変えて」（tweak）
  → 軽微判定 → 修正 → テスト全パス確認 → docs/TWEAKS.md に1行記録
  ※振る舞い・外部IF・テストに触れる場合は通常フローへ

（プロジェクト完成 → アップデート開発を始めるとき）
「節目処理をして」（milestone）
  → 要件定義書・API/DB仕様書のスナップショットを archive/ に凍結保存
  → 世代番号を+1（以降の文書は TICKET-NNN-02-slug.md のように新世代番号が付く）
```

## 1チケットのライフサイクル

```
「ユーザー登録APIのチケットを作って」（ticket-new）
  → チケットが draft で作成される
  → 人間がレビューし status: approved に変更     ← ゲート①

「TICKET-001 を開始して」（ticket-start）
  → 受入テストが作成され「失敗する」ことを確認
  → 人間がテスト内容を承認                        ← ゲート②
  → 実装し、全テストパスまで修正
  → 設計判断があればADRを起票（adr-new）

「TICKET-001 をレビューして」（ticket-review、実装とは別セッションで実行）
  → must / should / nice に分類した指摘＋対応方針を提示
  → 人間が対応方針を承認                          ← ゲート③
  → must を修正 → 再レビュー → must ゼロまで繰り返す
  → 経緯は docs/reviews/REVIEW-001 に全ラウンド記録

「TICKET-001 を完了して」（ticket-done）
  → 完了条件・レビューapproved・スコープ・外部IF一致・ADR記録を検証してクローズ
```

## Claude Code版との主な違い

- **カスタムプロンプト（`~/.codex/prompts/`）は非推奨**のため、スキル形式
  （`.agents/skills/`）で実装している。スキルはリポジトリにコミットでき、
  説明文にマッチすればCodexが自然言語からも呼び出す。
- **権限制御はプロジェクト単位ではなくグローバル**（`~/.codex/config.toml`）。
  個別コマンドのdenyリストではなく、承認ポリシー＋サンドボックスで制御する。
- 承認ゲート（要件・計画・チケット・受入テストでの停止）はAGENTS.mdとスキル本文の
  指示で実現しており、仕組みはClaude Code版と同じ。
