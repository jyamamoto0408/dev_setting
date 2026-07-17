---
description: 開発の節目処理（スナップショット保存＋世代インクリメント）を行う
argument-hint: <節目の説明 例: v1.0完成、通知機能アップデート開始>
---

プロジェクトの節目処理を以下の手順で行え。

節目: $ARGUMENTS

1. 前提確認: 現世代のPLANが全て `done`（未完了チケットがない）であることを確認する。
   未完了があれば列挙し、節目処理を進めてよいか人間に確認して停止する。
2. 現行世代番号（要件定義書の frontmatter `generation:`）を確認する。
3. 生きた文書のスナップショットを `archive/` に現世代番号付きで保存する:
   - `docs/requirements/requirements.md` → `docs/requirements/archive/requirements-<GG>.md`
   - `docs/interfaces/API.md` → `docs/interfaces/archive/API-<GG>.md`
   - `docs/interfaces/DB.md` → `docs/interfaces/archive/DB-<GG>.md`
   各スナップショットの冒頭に「世代<GG>時点の凍結文書。編集禁止。最新は元ファイルを参照」
   と追記する。既に同名のスナップショットがある場合は上書きせず停止して報告する。
4. 要件定義書の `generation:` を +1 し、変更履歴に節目を記録する
   （何が完成したか / 何のアップデートを始めるか）。
5. 処理結果（保存したスナップショット・新世代番号）を報告する。
   以降の新規文書（PLAN/TICKET/REVIEW/ADR/DESIGN）は新世代番号で作成される。
   次ステップとして要件定義書の更新（壁打ち）→ `/plan-new` を提案する。
