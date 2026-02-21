# Spec テンプレート

## 0. Spec ID
- spec_id: `<YYYYMMDD_short_name>`
- branch_name: `spec/<YYYYMMDD_short_name>`

## 1. 背景
- 課題と現状

## 2. 目的
- 実現したい状態

## 3. スコープ
- 実施対象

## 4. 非スコープ
- 実施しない対象

## 5. 要件
### 5.1 機能要件
- 必要機能

### 5.2 非機能要件
- 性能、セキュリティ、運用

## 6. 設計方針
### 6.1 Grain
### 6.2 Facts and Dimensions
### 6.3 Layering (Raw/Core/Mart)
### 6.4 Lineage
### 6.5 Partition Strategy
### 6.6 Scalability Considerations

## 7. 受け入れ条件
- チェックリスト

## 8. 実装タスク
1. タスク
2. タスク
3. タスク

## 9. テスト計画
- 単体/結合/運用確認

## 10. リスクと対策
- リスクと緩和

## 11. Assumptions
- 前提条件

## 12. 変更履歴
- YYYY-MM-DD: 初版作成

## ブランチ運用ルール（必須）
- 1 Spec につき 1 ブランチ（`1spec = 1branch`）
- ブランチは原則 `spec/<spec_id>` を使用する
- 同一ブランチで複数Specを扱わない
