# リポジトリ管理MCPの共通化（Codex/Gemini/Claude）

## 0. Spec ID
- spec_id: `20260215_repo_managed_mcp`

## 1. 背景
- Skillsは `.agents/skills/` に統合されたが、MCP設定はツールごとのローカル依存が残っている。
- repoに対してAIが直接実装・レビューするため、MCP設定もrepo正本として管理したい。

## 2. 目的
- `configs/mcp/` をMCP設定の正本としてGit管理する。
- Codex CLI / Gemini CLI / Claude Code で、repo設定を反映しやすい導線を用意する。
- Codex Web向けにはHTTP MCP依存をSkill定義で参照できる状態を維持する。

## 3. スコープ
- `configs/mcp/*.mcp.json` の整備
- 反映スクリプト追加（Codex/Gemini/Claude）
- 運用ドキュメント更新

## 4. 非スコープ
- GitHub Actions連携の実装
- HTTP MCPサーバのデプロイ
- シークレット管理基盤の構築

## 5. 要件
### 5.1 機能要件
- リポジトリ内MCP設定を単一正本として管理する。
- Codex CLIへは `codex mcp add` ベースで反映できる。
- Gemini/Claudeへは設定JSONをコピーまたはシンボリックリンクで反映できる。

### 5.2 非機能要件
- ローカル秘密情報はrepoに含めない。
- 手順は日本語で明記する。
- 設定反映が再実行可能であること。

## 6. 設計方針
### 6.1 Grain
- 1ツール = 1MCP設定ファイル

### 6.2 Facts and Dimensions
- Fact: MCPサーバ定義、反映スクリプト
- Dimension: ツール種別、反映方式（add/copy/symlink）

### 6.3 Layering (Raw/Core/Mart)
- Raw: ローカル既存MCP設定
- Core: `configs/mcp/*.mcp.json`
- Mart: `scripts/setup_mcp_for_tools.sh` と運用ドキュメント

### 6.4 Lineage
- Spec -> repo正本MCP -> 各ツールへ反映

### 6.5 Partition Strategy
- ツール別ファイル分割（codex/claude/gemini）

### 6.6 Scalability Considerations
- 追加ツールは同様に `configs/mcp/<tool>.mcp.json` とセットアップ手順を追加すれば対応可能。

## 7. 受け入れ条件（Acceptance Criteria）
- [ ] `configs/mcp/` が実運用可能な正本として整備される
- [ ] Codex/Gemini/Claude反映手順がスクリプトで提供される
- [ ] ドキュメントで「repo正本 + ローカル反映」の運用が明記される

## 8. 実装タスク
1. `claude.mcp.json` / `gemini.mcp.json` 実値化
2. 反映スクリプト作成
3. `docs/mcp_setup.md` 更新

## 9. テスト計画
- `bash -n scripts/setup_mcp_for_tools.sh`
- `scripts/setup_mcp_for_tools.sh help`
- `jq` 不要で設定反映が可能であることを目視確認

## 10. リスクと対策
- リスク: 各ツールの設定パス差異
- 対策: パスを引数で指定できるようにし、デフォルトを提供する

## 11. 未確定事項
- Codex Webで利用するHTTP MCPの本番URL

## 12. 変更履歴
- 2026-02-15: 初版作成
