# 高知観光ランキング｜プロジェクト移行後の基準状態

更新日: 2026-10-12

このファイルを、ChatGPT / Codex で高知観光ランキングを継続運用するときの基準にする。
明示的な変更指示がない限り、以下の仕様・運用方針を維持する。

## 公開・運用
- 公開URL: https://kochi-kanko-ranking.iriehair.workers.dev/
- 対象ディレクトリ: `kochi/`
- 本番ブランチ: `main`
- 基盤: GitHub / Cloudflare Workers
- 現在のフェーズ: 制作・主要UI/UX改善・最終QA完了。今後は運用、SEO、情報更新、必要な改善が中心。

## デザイン・UX
- スマートフォン最優先。基準幅390px。
- PC確認基準1440px。
- 個人制作サイトに見えない観光メディア品質を維持する。
- 高知の自然、海、川、食、文化を主役にする。
- トップ最上部のメイン写真は、明示指示がない限り変更しない。
- 横スクロールを発生させない。
- 主要操作は可能な限り40〜44px以上のタップ領域を確保する。
- 長い一覧はスマホで段階表示または横スワイプを活用する。

## 画像
- 使用許可・ライセンス確認済み画像のみ使用する。
- CC BY / CC BY-SA画像は必要なクレジットを表示する。
- 既存の確定済み画像を理由なく差し替えない。
- スマホ表示でのトリミングを優先確認する。

## 現在のスマホUX基準
- モデルコース一覧: 1列、初期4件。
- 人気アクティビティ: 初期8件＋残り表示。
- 特集: 初期4件＋残り表示。
- 検索結果: 初期4件＋残り表示。
- エリアおすすめ: 横スワイプ。
- スポット詳細「同じエリアのおすすめ」: 横スワイプ。
- 保存した旅: コンパクトカード＋並べ替え。
- スポット詳細上部: 保存 / 地図 / 公式サイトのクイックアクション。
- 投票ボタン: スマホ40px。
- ヘッダー主要操作: 40×44px基準。
- ヒーロースライドのドット: 見た目は小さく、実タップ領域30×30px。

## ランキング仕様
- 匿名ID × スポットIDで1票。
- 再クリックで解除。
- 掲載時は0票。
- 同票時は初期順位を使用。

## 正式アイコン
デザイン要素:
- 青い波
- 仁淀ブルーを想起する水
- 緑の山
- 金色の王冠

使用ファイル:
- `kochi/assets/icons/kochi-travel-icon.svg`
- `kochi/assets/icons/kochi-travel-icon-32.png`
- `kochi/assets/icons/kochi-travel-icon-64.png`
- `kochi/assets/icons/kochi-travel-icon-180.png`
- `kochi/assets/icons/kochi-travel-icon-192.png`
- `kochi/assets/icons/kochi-travel-icon-512.png`

サイト左上、favicon、iPhoneホーム画面、Android系アイコンで統一する。

## SEO基準
実装済み:
- index,follow
- canonical
- sitemap.xml
- robots.txt
- OGP
- Twitter Card
- JSON-LD
- Organization / WebSite / Breadcrumb
- H1は原則1ページ1つ
- Cloudflare Web Analytics

最終QA時:
- sitemap掲載URL 194件を確認。
- sitemap掲載URLのHTTP 200を確認。
- canonical欠落なし。
- index/follow不一致なし。
- 主要ページで画像欠損なし。
- JavaScript例外なし。
- 主要ページで横はみ出しなし。

Search Console:
- サイト側SEO設定は完了。
- Google側のクロール・インデックス反映を継続監視する。
- GSC Wizard連携では高知観光ランキングのプロパティが現在見えていないため、必要時に連携アカウントを確認する。

## パフォーマンス
- Leaflet JS は初期描画を阻害しないよう defer を維持する。
- 不要な画像の即時読み込みを増やさない。
- 既存のlazy loading方針を維持する。

## 変更時の必須確認
1. `npm run build:kochi`
2. `npm run test:kochi`
3. スマホ390px
4. PC1440px
5. 横はみ出し
6. 画像欠損
7. JavaScriptエラー
8. SEOメタ情報への影響
9. GitHub main反映
10. Cloudflare本番反映

本番変更時は、公開URLで実配信内容まで確認する。

## Codex運用
複数ファイル変更、JavaScriptロジック変更、Cloudflare/GitHub/ビルド関連、大規模UI調整、デバッグはCodex推奨。
ChatGPTからCodexへ渡す場合は、コピー＆ペーストできる指示文を作る。

## 運用
週次で公開状態を確認する。
監視対象:
- トップページ
- robots.txt
- sitemap.xml
- 主要ページHTTP状態
- canonical
- index/follow
- 明らかな表示障害
- Search Consoleが利用可能になればインデックス・検索パフォーマンス

## 今後の優先順位
1. Googleインデックス状況
2. Search Consoleの表示回数・クリック推移
3. Cloudflare Analytics
4. イベント・施設情報の鮮度維持
5. 検索流入データを基にコンテンツ強化
6. 必要な場合のみUI/UX追加改善

---
このファイルは「プロジェクト移行後の基準状態」。
大きな方針変更を行った場合のみ更新する。
