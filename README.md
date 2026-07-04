# TOMONI

TOMONIは、ふたりの関係を穏やかに育てるためのコミュニケーションアプリです。

現在は、外部APIやデータベースを使わずに動作するフロントエンドMVPです。入力した内容はブラウザの `localStorage` に保存されます。

## 必要な環境

- Node.js 20以上
- npm

## ローカルで起動する

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

現バージョンのデータは利用中のブラウザにのみ保存されます。別の端末やブラウザには同期されず、ブラウザの保存データを削除すると内容も消えます。

## ライセンス

ライセンスは未設定です。公開リポジトリで第三者による利用・改変・再配布を許可する場合は、目的に合う `LICENSE` を追加してください。
