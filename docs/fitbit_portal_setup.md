# Fitbit Web API ポータル設定手順（MVP: steps / Heart Rate / sleep）

## 1. 目的
- `fitbit-music ingest` を実行するために、Fitbit開発者ポータルで必要な設定を事前に完了する。
- 本手順は 2026-02-15 時点の Fitbit 公式ドキュメントに基づく。

## 2. 事前準備
- Fitbit アカウントを用意する。
- ローカルのコールバックURLを決める（例: `http://localhost:8080/callback`）。
- 本プロジェクトの `.env` を作成しておく（`.env.example` をコピー）。

## 3. 開発者ポータルでのアプリ登録
1. Fitbit Developer サイトにログインする。
- `https://dev.fitbit.com/`

2. 新規アプリ登録画面を開く。
- `https://dev.fitbit.com/apps/new`

3. アプリ情報を入力して作成する。
- App Name: 任意（例: `live-coding-music-dev`）
- Description: 任意（例: 個人利用の検証用アプリ。steps / heartrate / sleep を取得する。）
- Application Website URL: `http://localhost:8080` またはリポジトリURL
- Organization: 任意（例: 個人開発）
- Organization Website URL: GitHubプロフィールまたはリポジトリURL
- Terms of Service URL: 公開URL（草案: `docs/legal/terms.md`）
- Privacy Policy URL: 公開URL（草案: `docs/legal/privacy.md`）
- OAuth 2.0 Application Type: `Personal`（開発者本人アカウント向け）
- Callback URL: `http://localhost:8080/callback`（実際に使う値と完全一致）
- Default Access Type: `Read Only`（取得のみのため）

4. 作成後、`Client ID` と `Client Secret` を控える。
- `Personal` アプリではトークン交換時に `client_secret` なしでも成立するが、将来 `Server` へ変更する可能性があるなら保持しておく。

## 4. OAuth 設定（Authorization Code Grant + PKCE）
1. 認可URLを作成してブラウザで開く。
- エンドポイント: `https://www.fitbit.com/oauth2/authorize`
- 必須パラメータ:
  - `client_id`
  - `response_type=code`
  - `scope`
  - `code_challenge`
  - `code_challenge_method=S256`
- 推奨パラメータ:
  - `redirect_uri`（アプリ設定で複数登録時は必須。単一でも付与運用を推奨）
  - `state`（CSRF対策）

2. 同意後、コールバックURLに `code` が付与されるので取得する。

3. トークンエンドポイントで Access Token / Refresh Token を取得する。
- エンドポイント: `https://api.fitbit.com/oauth2/token`
- Grant Type: `authorization_code`
- 主要パラメータ:
  - `client_id`
  - `code`
  - `redirect_uri`（authorize 時に指定した値と完全一致）
  - `code_verifier`
- `Personal` アプリでは Basic 認証（`client_secret`）なしで実行可能。

4. 取得した値を `.env` に設定する。
- `FITBIT_CLIENT_ID`
- `FITBIT_CLIENT_SECRET`
- `FITBIT_REDIRECT_URI`
- `FITBIT_ACCESS_TOKEN`
- `FITBIT_REFRESH_TOKEN`

## 5. スコープ設定（このリポジトリのMVP）
- `activity`（steps 取得に使用）
- `heartrate`（Heart Rate 取得に使用）
- `sleep`（sleep 取得に使用）

推奨例（認可URLの `scope`）:
- `activity heartrate sleep`

## 6. このプロジェクトでの設定反映
1. `.env` に OAuth 情報を反映する。
2. 必要なら Raw 保存先を変更する。
- `FITBIT_RAW_DIR`（未指定時は `data/raw`）

3. 動作確認（トークン設定後）
```bash
python -m fitbit_music.cli ingest --since 2026-02-15 --until 2026-02-15 --endpoints steps
```

## 7. よくある失敗
- Callback URL 不一致: ポータル登録値と `redirect_uri` が1文字でも違うと失敗する。
- Scope 不足: `activity`/`heartrate`/`sleep` が不足すると API が 403 になる。
- authorization code 失効: `code` は発行から10分で失効する。
- Token 期限切れ: Authorization Code Grant（PKCE）の Access Token は通常 8時間（`28800`秒）で期限切れになる。
- redirect_uri 不一致: ポータル設定値 / authorize リクエスト / token リクエストの3者を完全一致させる。

## 8. 参照（公式）
- Authorization Guide:
  - `https://dev.fitbit.com/build/reference/web-api/developer-guide/authorization/`
- Authorization Code Grant Flow:
  - `https://dev.fitbit.com/build/reference/web-api/developer-guide/authorization/code-grant-flow/`
- Authorize Endpoint:
  - `https://dev.fitbit.com/build/reference/web-api/authorization/authorize/`
- Token Endpoint:
  - `https://dev.fitbit.com/build/reference/web-api/authorization/get-access-token/`
- Application Design:
  - `https://dev.fitbit.com/build/reference/web-api/developer-guide/application-design/`
  - Scopes セクションを参照する。
