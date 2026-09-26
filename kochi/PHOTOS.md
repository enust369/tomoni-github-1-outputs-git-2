# 写真差し替え記録（第1弾）

調査日: 2026-09-21。開始commit: 046f82c95a7000cce7246228d0ceecd6e0512dbe。

## 変更前の参照一覧

すべてのスポット・コースが共通画像 R を参照。スポット詳細・コース立ち寄り先も同じ。コース詳細ヒーローと地図下の装飾画像は R を直接参照。全ページ共通ヒーローも R。

R: https://visitkochijapan.com/image/rendering/article_image/1948/keep/640/640/db_image.jpg?v=8ff65f857206a6fac170ecdface66a65ec6794d7

| 種別 | slug | 名称 | 現在画像 |
|---|---|---|---|
| spot | ryugado | 龍河洞 | R |
| spot | nikobuchi | にこ淵 | R |
| spot | iokido | 伊尾木洞 | R |
| spot | kochi-castle | 高知城 | R |
| spot | kashiwajima | 柏島 | R |
| spot | yasui | 安居渓谷 | R |
| spot | nakatsu | 中津渓谷 | R |
| spot | monet | 北川村「モネの庭」マルモッタン | R |
| spot | muroto | 室戸岬 | R |
| spot | karst | 四国カルスト | R |
| spot | yusuhara | 梼原 | R |
| spot | ashizuri | 足摺岬 | R |
| spot | myojinmaru | 明神丸 ひろめ市場店 | R |
| spot | yasube | 屋台安兵衛 | R |
| spot | hashimoto | 橋本食堂 | R |
| spot | tanaka | 田中鮮魚店 漁師小屋 | R |
| spot | shirasu | 安芸しらす食堂 本店 | R |
| spot | ice | 高知アイス売店 仁淀川カフェ | R |
| spot | kayak | 仁淀川シーカヤック | R |
| spot | sauna | Niyodo Adventureのテントサウナ | R |
| course | kochi-classic | 高知市内 王道1日コース | R |
| course | niyodo-classic | 仁淀ブルー 王道1日コース | R |
| course | niyodo-active | 仁淀川 アクティブ満喫1日コース | R |
| course | east-drive | 東部絶景＆しらすグルメ1日コース | R |
| course | ocean-trip | 柏島・足摺 海の1泊2日コース | R |
| course | karst-drive | 四国カルスト・梼原 絶景ドライブ | R |
| course | kochi-gourmet | 高知市内 グルメ満喫1日コース | R |
| course | kami-konan | 龍河洞・香美香南 1日コース | R |
| course | family | 高知 子連れ1日コース | R |
| course | three-days | 高知満喫2泊3日コース | R |

## 採用方針

- 最優先10スポットのみ実写真を選定。次点10スポットは写真未設定とし、共通の別施設写真へ戻さない。
- 公式フォトライブラリーを優先確認したが事前申請が必要。申請・許諾取得をしていない素材は利用しない。https://kochi-tabi.jp/corp/photo_library.html?id=161 （利用申請、利用1回、画像直接リンク禁止）。https://higashi-kochi.jp/photo/ （申請制）。
- Wikimedia Commonsはサイト全体のライセンスではなく個別ファイルの著作者・ライセンス・説明・実画像を確認。写真ごとのクレジットとライセンスへのリンクを画面に表示する。
- CC BY-SA 3.0/4.0: 著作者・出典・ライセンス・変更内容を表示。写真のリサイズ／表示トリミング部分は同じライセンス。サイトのコードとは別。CC0はクレジット義務なしだが出典を記載。
- 外部ホットリンクを避け、確認済みの1280px写真をkochi/assets/photos/へ同梱。色加工・生成補完なし。
- コース写真は立ち寄り先の許諾確認済み写真を使用し、撮影場所を明記。別スポットへの写真流用はしない。
- 安居渓谷: 公式の利用許諾未取得、適切なフリーライセンス候補を確認できず未設定。候補: https://kochi-tabi.jp/search_spot.html?id=693 、申請窓口: https://kochi-tabi.jp/corp/photo_library.html 。

## 最終候補と実装対象（実装前に確認）

| 対象 | 現在画像 | 新画像 | 出典・撮影者 | 使用条件 |
|---|---|---|---|---|
| 龍河洞 | R | `ryugado.jpg`（龍河洞の鍾乳石「奥の千本」） | [京浜にけ / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Kami_Kochi_Ryugado_Inside_4.JPG) | [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0)・表示／縮小・トリミング明記・写真の派生物は同一ライセンス |
| にこ淵 | R | `nikobuchi.jpg`（にこ淵の青い滝つぼと滝） | [かるちる / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Niko_Buchi_deep_water_No.1.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en)・表示／縮小・トリミング明記 |
| 伊尾木洞 | R | `iokido.jpg`（伊尾木洞のシダに覆われた岩壁） | [Saigen Jiro / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Iokido_Cave-2.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en)・表示／縮小・トリミング明記 |
| 高知城 | R | `kochi-castle.jpg`（高知城の天守と石垣） | [663highland / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Kochi_Castle04s3872.jpg) | [CC BY 2.5](https://creativecommons.org/licenses/by/2.5)・表示／縮小・トリミング明記 |
| 柏島 | R | `kashiwajima.jpg`（柏島の集落と青い海を見渡す全景） | [Saigen Jiro / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Kashiwajima_(Otsuki),_zenkei-1.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en)・表示／縮小・トリミング明記 |
| 中津渓谷 | R | `nakatsu.jpg`（中津渓谷の清流と岩場） | [Koda6029 / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:%E4%B8%AD%E6%B4%A5%E6%B8%93%E8%B0%B7%EF%BC%92.jpg) | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0)・表示／縮小・トリミング明記・写真の派生物は同一ライセンス |
| 北川村「モネの庭」マルモッタン | R | `monet.jpg`（北川村「モネの庭」マルモッタンの水の庭） | [Earthboud1960 / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Monet-Marumottan-mizu02.jpg) | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0)・表示／縮小・トリミング明記・写真の派生物は同一ライセンス |
| 室戸岬 | R | `muroto.jpg`（室戸岬の岩礁と太平洋） | [Rsa / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Cape-Muroto-20100526.jpg) | [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/)・表示／縮小・トリミング明記・写真の派生物は同一ライセンス |
| 四国カルスト | R | `karst.jpg`（四国カルストの草原と石灰岩） | [Raita Futo from Tokyo, Japan / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Shikoku_Karst_(52004285742).jpg) | [CC BY 2.0](https://creativecommons.org/licenses/by/2.0)・表示／縮小・トリミング明記 |
| 安居渓谷 | R | 未設定 | [公式候補](https://kochi-tabi.jp/search_spot.html?id=693) | 許諾未確認のため不採用 |

CC BY 2.0/2.5は著作者・出典・ライセンス・変更を表示。写真は撮影当時の姿であり現況保証はしない。

未採用候補: モネmizu01は看板主体、中津渓谷.jpgは鯉のぼりが目立つ、高知城20170122-3は夜景のため昼景を選択。

## 再開後の実装記録

共通仁淀川写真は過去READMEでも権利確認を公開条件としており、許諾確認の記録がありません。「使用条件を確認できない写真は使わない」を優先し、未設定時は実写真ではない `unset.svg` を表示します。旧写真のURLは上の調査記録にのみ保管します。

`main_image_url` は採用済み9件のみ `/assets/photos/{slug}.jpg`、未設定は空文字。画面は実写真のaltとクレジットを写真台帳から共通描画。投票後・絞り込み後の再描画も同じ写真と出典を保持します。

### 高知県立牧野植物園

`makino-botanical-garden.png` はサイト掲載用に提供された画像を、加工せずそのまま登録。スポット slug `makino-botanical-garden` にのみ紐付け、カードと詳細ページで共通利用します。

### コースのメイン写真

| コース | 写真のスポット |
|---|---|
| 高知市内 王道1日コース | 高知城 |
| 仁淀ブルー 王道1日コース | にこ淵 |
| 仁淀川 アクティブ満喫1日コース | 中津渓谷 |
| 東部絶景＆しらすグルメ1日コース | 伊尾木洞 |
| 柏島・足摺 海の1泊2日コース | 柏島 |
| 四国カルスト・梼原 絶景ドライブ | 四国カルスト |
| 高知市内 グルメ満喫1日コース | 未設定（対象スポットの写真未確認） |
| 龍河洞・香美香南 1日コース | 龍河洞 |
| 高知 子連れ1日コース | 高知城 |
| 高知満喫2泊3日コース | 高知城 |

立ち寄り先は各スポットと同じ写真。各コースに含まれるスポットのうち写真確認済みの先頭をメイン写真として使用し、クレジットに場所を表示。

## 検証結果

- `npm run build:kochi`: 57ルート生成成功。既存テスト3件成功。
- 390px / 1440px: トップ、ランキング、コース一覧・詳細、スポット詳細、未設定表示、グルメ一覧で画像読み込み・alt・ページ横はみ出しなし。
- 9枚の画像URLは各スポットで一意。出典・ライセンスリンクをカード、詳細、立ち寄り先、ヒーローに表示。旧仮画像への実行時参照なし。
- 写真差替え後の静的ビルドをブラウザーに読み込ませ、既存本番D1 APIへ接続。投票0→1→0と両状態の再読み込み、掲載・修正申請201/pendingと受付表示を確認。ブラウザーエラーなし。
- テスト申請識別子: `PHOTO-QA-20260921-1`（削除可能・掲載／修正反映不要を明記）。掲載ID: `bc0d1aee-c815-40ac-9eb1-9b96c04a2608`、修正ID: `afdf23fb-0f82-4581-9d40-4f66aa158027`。本番DBの構造変更・migrationなし。
- `kochi/app.mjs`、`kochi/worker.mjs`、`kochi/wrangler.jsonc`およびTOMONIに差分なし。

## 写真差し替え記録（第2弾）

調査・実装日: 2026-09-23。第1弾の9件を変更せず、未設定だった11件を個別に再確認した。外部ホットリンクは使わず、採用した3件はWikimedia Commonsから取得した画像を `kochi/assets/photos/` に同梱している。

| 対象 | 使用画像 | 出典・撮影者 | ライセンス / 利用条件 | クレジット |
|---|---|---|---|---|
| 安居渓谷 | `yasui.jpg`（飛龍の滝） | [ball banban / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:%E9%A3%9B%E9%BE%8D%E3%81%AE%E6%BB%9D_-_panoramio.jpg) | [CC BY 3.0](https://creativecommons.org/licenses/by/3.0)。商用利用・改変可。著作者、出典、ライセンス、縮小・表示トリミングの明記が必要。 | 必要（画面で表示） |
| 梼原 | `yusuhara.jpg`（梼原町のゆすはら座外観） | [osami / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:1yusuharaza.jpg) | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en)。商用利用・改変可。クレジットは任意だが出典記録と画面表示を継続。 | 任意（画面で表示） |
| 足摺岬 | `ashizuri.jpg`（断崖と足摺岬灯台） | [Reggaeman / Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Ashizuri_Cape_01.JPG) | [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0)。商用利用・改変可。著作者、出典、ライセンス、縮小・表示トリミングの明記および写真の派生物の同一ライセンスが必要。 | 必要（画面で表示） |

### 未設定を維持した対象

| 対象 | 結果 |
|---|---|
| 明神丸 ひろめ市場店 | 施設に一致し、利用条件を確認できる写真を確認できなかったため未設定。 |
| 屋台安兵衛 | 施設に一致し、利用条件を確認できる写真を確認できなかったため未設定。 |
| 橋本食堂 | 施設に一致し、利用条件を確認できる写真を確認できなかったため未設定。 |
| 田中鮮魚店 漁師小屋 | 施設に一致し、利用条件を確認できる写真を確認できなかったため未設定。 |
| 安芸しらす食堂 本店 | 施設に一致し、利用条件を確認できる写真を確認できなかったため未設定。 |
| 高知アイス売店 仁淀川カフェ | 施設に一致し、利用条件を確認できる写真を確認できなかったため未設定。 |
| 仁淀川シーカヤック | 事業者・体験に一致し、利用条件を確認できる写真を確認できなかったため未設定。 |
| Niyodo Adventureのテントサウナ | 事業者・体験に一致し、利用条件を確認できる写真を確認できなかったため未設定。 |

未設定には旧仁淀川写真を再利用せず、既存の `unset.svg` を使う。`photos.mjs` の台帳へ3件を追加したため、スポットカード、詳細、ランキング、コース立ち寄り先は同じ出典・alt・クレジットを参照する。コースのメイン写真は既存の先頭採用写真選択を維持する。
