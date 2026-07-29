# TOMONI

TOMONIは、ふたりの関係を穏やかに育てるためのコミュニケーションアプリです。

認証にはSupabase Authenticationを利用します。プロフィール、募集、参加情報などのサービスデータはSupabaseに保存され、ブラウザにはログイン中の利用者に紐づく画面状態だけを保存します。

募集内容は `listings`、参加申請と承認状態は `listing_participants`、チャットは `listing_messages`、会った記録は `meeting_records`、プロフィールは `profiles`、通知は `notifications` テーブルに保存します。プロフィール写真は `profile-photos` Storageバケットへ保存します。承認済みの参加者だけが人数に含まれ、チャットと会った記録を利用できます。会った記録と通知は本人だけが閲覧できます。参加申請・審査・チャット・通知はSupabase Realtimeで即時反映されます。初回またはSQL更新時に、Supabase DashboardのSQL Editorで [`supabase-listings.sql`](./supabase-listings.sql) を実行してください。テーブル、プロフィール写真バケット、承認制の参加処理、通知トリガー、Realtime設定、インデックス、Row Level Securityのポリシーが作成されます。

## 必要な環境

- Node.js 20以上
- npm

## ローカルで起動する

`.env.example` を参考に `.env` を作成し、SupabaseのProject URLとanon keyを設定します。

```bash
VITE_SUPABASE_URL=your-project-url
VITE_SUPABASE_ANON_KEY=your-anon-key
```

```bash
npm install
npm run dev
```

ターミナルに表示されるURLをブラウザで開いてください。

## 本番用にビルドする

```bash
npm run build
npm run preview
```

ビルド成果物は `dist` に生成されます。`dist` はGit管理しません。

## Cloudflare Pagesへデプロイする

- Build command: `npm run build`
- Publish directory: `dist`
- Node.js: 20

Cloudflare PagesでGitHubリポジトリを連携し、上記のビルド設定とSupabase環境変数を設定してください。

## ディレクトリ構成

```text
.
├── index.html       # TOMONIアプリ本体
├── _headers         # Cloudflare Pages用セキュリティヘッダー
├── sitemap.xml      # サイトマップ
├── robots.txt       # クローラー設定
├── assets/          # ブランド素材
├── package.json     # 開発・ビルド設定
├── package-lock.json
├── scripts/         # ローカル起動・ビルド用スクリプト
└── README.md
```

## データについて

プロフィール、診断結果、募集、参加状態はSupabaseに保存されます。会員登録後はSupabaseから送信される確認メール内のリンクでメール確認を完了し、その後ログインして利用します。パスワードはブラウザ内やアプリ独自の保存領域には保存しません。

## ライセンス

ライセンスは未設定です。公開リポジトリで第三者による利用・改変・再配布を許可する場合は、目的に合う `LICENSE` を追加してください。
