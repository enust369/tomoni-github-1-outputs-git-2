# 高知観光ランキング MVP

既存TOMONIを変更せず、独立した `kochi/` に追加したWebサイトです。Node.js 20以上、外部npm依存なし。ルートの既存 `dev` / `build` とSupabase設定は変更していません。

## 起動・ビルド

```sh
npm run dev:kochi    # http://127.0.0.1:4174
npm run build:kochi  # kochi/dist に静的HTMLを出力
npm run test:kochi
```

専用サイトの `/` から各URLを提供します。TOMONIの `/` を置き換える構成ではありません。公開時は `kochi/dist` を別サイトのルートとして配信してください。directory index と404ページをサポートするホストを使用します。

## ページ

トップ、10カテゴリのランキング、モデルコース一覧／詳細10件、スポット詳細20件、イベント一覧／サンプル詳細、4エリア、追加・修正申請、ログイン／マイページ枠、about/contact/terms/privacy、検索。プレビューは計57ルート。

ランキングは実票降順・初期順位昇順。TOP5をカード表示し、それ以降を「みんなのおすすめ」に表示。モデルコースの人気集計は未実装のため、運営おすすめ順と明示しています。

## 主要ファイル

- `data.mjs`: 未確認の初期掲載候補、コース、分類、順位ロジック
- `render.mjs`: 全ページの共通テンプレート、SSR/静的HTML、ルート一覧
- `styles.css`: 白・青・緑の共通UI、390px対応
- `app.mjs`: フィルター、検索、投票、申請フォーム
- `content.mjs`: Supabase公開データのページング取得（500件ずつ）
- `scripts/server.mjs`: 専用ローカルサーバー。接続時は公開データを60秒キャッシュ
- `scripts/build.mjs`: ページ別title/meta/canonical/OGP、サイトマップ生成
- `supabase/migrations/001_initial.sql`: 12テーブル、RLS、投票・申請RPC
- `supabase/demo-seed.sql`: 開発専用、0票の未確認候補を投入する任意fixture

## Supabase接続

**TOMONIとは別の新規Supabaseプロジェクト**でmigrationを適用します。既存TOMONIのprofiles等と同名のため、既存DBへ実行しないでください。

1. `supabase/migrations/001_initial.sql` を専用プロジェクトへ適用。
2. Authenticationで匿名ログインを有効化。
3. 開発検証だけなら `supabase/demo-seed.sql` を適用。本番へこのfixtureを流さない。
4. 下記の環境変数を設定してdev/buildを実行（`.env` の自動読込はありません）。静的配信時はbuildで `config.js` へ公開用キーを埋め込みます。service_roleはブラウザへ渡しません。

```sh
export KOCHI_SUPABASE_URL='https://YOUR_PROJECT.supabase.co'
export KOCHI_SUPABASE_ANON_KEY='YOUR_PUBLIC_ANON_KEY'
export KOCHI_SITE_URL='https://YOUR_DOMAIN'
npm run build:kochi
```

未接続時は明示したプレビュー動作です。投票は実際に押した分だけこのブラウザで0/1を保存します。全利用者の票ではなく、公開DBに加算されません。申請はブラウザの下書き保存のみで、送信済みとは表示しません。認証セッションや下書きを削除するにはブラウザのサイトデータを削除してください。

接続時はSupabase匿名AuthのIDを `anonymous_id` として使用。クライアントが任意の別人IDを指定できないRPCです。`spot_id + anonymous_id` の主キー、スポット行ロック、トリガーによる件数更新で重複・競合に対応。投票は1分20操作、申請は1分3件まで。レート制限と処理は同一トランザクション。IPは保存しません。サイトデータ削除・別ブラウザによる別ID発行を防ぐ高度な検知は後回しです。

申請RPCはstatusを受け付けず、常にpending。匿名ユーザーは申請者のメールや申請一覧を読み取れません。運営はDashboard等で審査し、承認済み提案の公開にはservice_role専用 `approve_suggestion(p_id,p_slug,p_rank)` を使用します。新規公開は0票。修正申請は審査後に施設データを更新し、statusをapprovedへ変更します。複雑な管理画面はありません。

接続時は公開スポット・コース・イベントをDBから取得。追加公開後は静的サイトを再ビルドして詳細ページとサイトマップを生成してください。動的な専用devサーバーでは60秒以内に新規ルートも反映します。

## データ・写真・公開前作業

- 初期施設名・コースは依頼内容に基づく未確認候補。営業時間・価格・営業日等を捏造せず未確認表示。
- 本番DBは空から開始。運営が一次情報と写真の権利を確認して登録してください。
- 写真第1弾: 最優先10件中9件に、個別ライセンス確認済みの写真をローカル同梱。安居渓谷と第2弾対象は写真未設定。出典・条件・変更前一覧は [PHOTOS.md](PHOTOS.md)、画面用メタデータは `photos.mjs`。共通仮写真へのフォールバックはありません。
- 2030年の架空イベントは表示検証用。通常の一覧から除外し、チェックを入れたときだけ表示。イベントseedには含めていません。
- 所要時間は仮の目安。移動時間、予約、日跨ぎの詳細行程、体験場所は公開前に精査が必要。
- 公式サイトURL等は公開前に確認。利用規約・プライバシーは草案。運営者情報と一般問い合わせ窓口を確定してください。
- 未設定ドメインのプレビューはnoindex。`KOCHI_SITE_URL` 設定でcanonicalとsitemap.xmlが有効になります。公開作業は今回実施していません。

## 検証

`node --test scripts/test.mjs` は全57ページ、内部リンク、0票開始、順位ロジック、404、SEOを検証します。
`scripts/browser-check.mjs` はPlaywright + インストール済みChromeで全ルート390px幅を巡回し、横方向のはみ出し、JS例外、投票と取消・再読込、絞り込み、検索、イベント、申請下書きを確認します。Playwright importはこの作業環境のランタイムパスです。別環境ではPlaywrightを導入しimportを調整してください。

Supabase接続先が未設定のため、migrationの実DB適用・並行投票・Auth/RLS/RPCの統合試験は未実施です。公開前に専用開発DBで検証してください。

## 後回し

本格口コミ／星評価、会員画面、お気に入り・マイコース、写真投稿、店舗オーナー管理、高度な不正検知、人気コース集計・急上昇集計、一般問い合わせ送信。サイクリング・キャンプ・温泉・道の駅・宿泊・釣り・サーフィンは共通画面と空状態を実装し、確認済み掲載先の選定を待っています。
