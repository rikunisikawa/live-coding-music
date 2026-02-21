# Agent 出力テンプレート

```text
Agent: <architect|infra|data|backend|test|review>
Task: <実施した作業>
Output: <成果物パスと要約>
Next Action: <次の担当Agentに引き継ぐ内容>
```

## 記入ルール
- Outputには必ずファイルパスを含める。
- Next Actionでは次のStepと担当Agentを明示する。
- 重大な未解決事項がある場合はTask末尾に `BLOCKED` を付与する。
