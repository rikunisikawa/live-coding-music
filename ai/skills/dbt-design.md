# dbt 設計ガイドライン

## レイヤー設計: staging / core / mart
- staging: 型変換、命名正規化、ソース整合など最小限の整形。
- core: 共有可能なエンティティやFact、共通ビジネスロジック。
- mart: 目的別に最適化された分析・レポート向けデータ。

## Incremental モデル設計
- `materialized='incremental'` と安定した `unique_key` を使用。
- `updated_at` やイベント時刻で差分条件を定義。
- 遅延到着データにはローリングウィンドウを考慮。

## Surrogate Key の使い方
- 自然キーが不安定または複合の場合はサロゲートキーを付与。
- 再現性のあるハッシュ生成を推奨。
- キー構成と一意性テストを明記。

## Snapshot の使い方
- SCDが必要な場合にスナップショットを利用。
- `unique_key` と `updated_at` もしくは `check` 戦略を適切に設定。
- スナップショット専用スキーマと保持ポリシーを明示。

## dbt test 設計
- 基本テスト: `not_null`, `unique`, `accepted_values`, `relationships`。
- 重要な主キー/外部キー/指標にテストを追加。
- ソースおよびステージングの鮮度テストを含める。
