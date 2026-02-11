# Fitbit API 主要エンドポイント（初期調査メモ）

※ 実装前提の概略整理。詳細仕様はFitbit公式ドキュメントで確認すること。

## Heart Rate
- Intraday Heart Rate Time Series
- 日次サマリ / 分単位データを取得想定

## Sleep
- Sleep Logs
- 睡眠ステージ（deep/light/rem/awake）を想定

## Activities / Steps
- Activities Logs
- Step count / activity summary

## 想定する取得頻度と制約
- MVPはポーリング方式（since/until）
- レート制限・トークン更新の挙動を考慮して設計
- 初期ポーリング間隔は未確定（requirementsで管理）
