# Agent Teams 運用構造

このディレクトリは、医療データ基盤向けの Agent Teams 実行成果物とテンプレートを管理する。

## 構成
- `workflow/`: 実行順序とゲート定義
- `templates/`: Agent出力テンプレート
- `outputs/architecture/`: Architect成果物
- `outputs/infra/`: Infra成果物
- `outputs/data/`: Data成果物
- `outputs/backend/`: Backend成果物
- `outputs/tests/`: Test成果物
- `outputs/review/`: Review成果物

## 実行原則
- Architect設計未完了なら実装禁止
- AWS変更はTerraform経由のみ
- Test/Review未完了の実装は完了扱いにしない
- 本番前に人間承認を必須とする
