# Terraform ベストプラクティス スキル

## ベストプラクティス
- backend を環境別に分離し、stateロックを有効化する。
- `modules/` で責務ごとに分割し再利用性を確保する。
- `terraform fmt`, `validate`, `plan` をCIで必須化する。
- 変数は `variables.tf` と `*.tfvars` で明示的に管理する。

## 設計原則
- 宣言的定義を唯一のAWS変更経路にする。
- `plan` の差分レビューを承認ゲートにする。
- 破壊的変更は事前に影響範囲とロールバック手順を記述する。

## アンチパターン
- `terraform apply` をローカル手動で直接本番実行する。
- module化せず単一巨大 `main.tf` に集約する。
- stateファイルをローカルのみで運用する。
