# インフラ構造

- packages/infra/modules: 再利用可能モジュール
- packages/infra/env: 環境別の変数ファイル

実行は `scripts/run_in_container.sh terraform-plan` を使用する（`APP_ENV` で環境切替）。
