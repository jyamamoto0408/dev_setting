---
id: TICKET-NNN
title: （1機能を表す短いタイトル）
status: draft   # draft → approved → in-progress → in-review → done
created: YYYY-MM-DD
adr: []         # このチケットで起票したADRの番号（例: [ADR-0003]）
review:         # レビュー記録（REVIEW-NNN、チケットと同番号）
---

# TICKET-NNN: タイトル

## 関連ドキュメント

このチケットの根拠となる上流文書。トレーサビリティのため必ず記載する。

- 要件: REQ-F-NN（`docs/requirements/requirements.md`）
- 計画書: PLAN-NNN（このチケットを含む実装計画。開発順序の第何ステップかも書く）
- 詳細設計: DESIGN-NN §該当節（作成した場合のみ）
- 外部IFへの影響: なし / あり（`docs/interfaces/API.md` / `DB.md` の更新が必要）

## 目的（Why）

この機能が必要な理由。誰のどんな課題を解決するか。

## 実装内容（What）

- やること1
- やること2

対象ファイル/モジュール（想定）:
- `src/...`

## 対象外（Out of Scope）

- やらないこと1（例: エラーリトライは別チケット）
- やらないこと2

## 完了条件（Acceptance Criteria）

各条件は受入テストと1対1で対応させること。

- [ ] AC-1: （観測可能な振る舞いで書く。「〜すると〜になる」形式）
- [ ] AC-2: 
- [ ] AC-3: 

## 受入テスト

- テストファイル: `tests/...`（フェーズ2で記入）

## メモ

実装中に判明したこと、スコープ外として切り出した項目など。
