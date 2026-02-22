# dbt ベストプラクティス スキル

## ベストプラクティス
- `staging/core/mart` の3層を維持する。
- `schema.yml` で `not_null`, `unique`, `relationships` を定義する。
- incremental モデルは `unique_key` と差分条件を固定する。
- 重要モデルは description と lineage を明記する。

## 設計原則
- SSOTをcore層で確立し、martは用途別派生に限定する。
- Fact/Dimension を分離し、粒度を明示する。
- 遅延到着データの再処理ウィンドウを定義する。

## アンチパターン
- mart層で生データ補正ロジックを持つ。
- テストなしで本番モデルを追加する。
- モデル粒度を明示せず結合を繰り返す。
