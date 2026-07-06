# TOMONI

TOMONIは、ふたりの関係を穏やかに育てるためのコミュニケーションアプリです。

認証にはSupabase Authenticationを利用します。プロフィールなどの端末設定はブラウザに、募集内容はSupabaseに保存されます。

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

## Netlifyへデプロイする

このリポジトリには `netlify.toml` が含まれているため、NetlifyでGitHubリポジトリを連携すれば設定が自動で読み込まれます。

- Build command: `npm run build`
- Publish directory: `dist`
- Node.js: 20

Netlifyの **Add new project** → **Import an existing project** からGitHubリポジトリを選び、デプロイしてください。

## ディレクトリ構成

```text
.
├── index.html       # TOMONIアプリ本体
├── netlify.toml     # Netlify設定
├── package.json     # 開発・ビルド設定
├── package-lock.json
├── scripts/         # ローカル起動・ビルド用スクリプト
└── README.md
```

## データについて

プロフィールや診断結果などの端末設定は利用中のブラウザに保存されます。作成した募集と参加状態はSupabaseに保存されるため、リロード後も残ります。

会員登録・ログイン・ログアウト・パスワード再設定を試せます。メール確認コードはMVP用の `123456` が画面に自動入力されます。パスワードはソルト付きハッシュとしてブラウザに保存しますが、サーバー認証ではないため、本番運用では認証基盤とデータベースへの置き換えが必要です。

## ライセンス

ライセンスは未設定です。公開リポジトリで第三者による利用・改変・再配布を許可する場合は、目的に合う `LICENSE` を追加してください。
