---
name: adr-new
description: 重要な設計判断をADR（Architecture Decision Record）として記録する。新規ライブラリ導入、スキーマ/API決定、複数案からの選択、トレードオフの受け入れ、既存設計からの逸脱があったとき、または「ADRを書いて」と言われたときに使う。
---

# ADR起票

以下の手順でADRを起票する。

1. `docs/adr/` を確認し、次のADR番号を決める。
2. `docs/adr/_TEMPLATE.md` を元に `docs/adr/ADR-NNNN-<GG>-<slug>.md` を作成する
   （GG＝要件定義書の frontmatter `generation:` の現行世代番号）。
3. 特に「検討した代替案」と「受け入れたトレードオフ」を具体的に書く。
   会話の文脈から代替案が読み取れない場合はユーザーに確認する。
4. 過去のADRと矛盾する決定の場合は、古いADRの `status` を
   `superseded by ADR-NNNN` に更新する（本文は書き換えない）。
5. 関連チケットがあれば、チケットの `adr:` に番号を追記する。
