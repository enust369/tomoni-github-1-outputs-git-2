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
| spot | myojinmaru | 明神丸 本店 | R |
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
| 高知城 | R | `kochi-castle-new.png`（青空の下にそびえる高知城の天守と石垣） | ユーザー提供画像を加工 | 提供画像（サイト掲載用） |
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

### 歴史文化スポット用の提供画像

歴史文化スポット用の画像は各スポット専用として登録し、他施設へ流用しません。竹林寺は2026-10-01に人物を除去して軽く調整した縦位置の新画像へ差し替え、その他3件は従来の2×2分割画像を継続使用します。

| スポット | ファイル | alt | 出典 |
|---|---|---|---|
| 竹林寺 | `chikurinji-pagoda.png` | 新緑に囲まれた竹林寺の五重塔と石段 | ユーザー提供画像を加工 |
| 高知県立高知城歴史博物館 | `kochi-castle-history-museum.png` | 青空の下に建つ高知県立高知城歴史博物館 | ユーザー提供画像（2×2分割） |
| 高知県立坂本龍馬記念館 | `sakamoto-ryoma-memorial-museum.png` | 青空と海を望む高知県立坂本龍馬記念館 | ユーザー提供画像（2×2分割） |
| 潮江天満宮 | `shioe-tenmangu.png` | 緑に囲まれた潮江天満宮の参道と社殿 | ユーザー提供画像（2×2分割） |

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
| 仁淀川シーカヤック | `sea-kayak.jpg` をユーザー提供の加工済み画像として使用。外部ホットリンクなし。 |
| Niyodo Adventureのテントサウナ | 事業者・体験に一致し、利用条件を確認できる写真を確認できなかったため未設定。 |

未設定には旧仁淀川写真を再利用せず、既存の `unset.svg` を使う。`photos.mjs` の台帳へ3件を追加したため、スポットカード、詳細、ランキング、コース立ち寄り先は同じ出典・alt・クレジットを参照する。コースのメイン写真は既存の先頭採用写真選択を維持する。


## 歴史文化用追加画像（2026-09-30）

以下4点は、ユーザー提供の加工済み画像を分割してサイト内アセットとして使用。外部ホットリンクなし。

- 竹林寺: `chikurinji-pagoda.png`（ユーザー提供画像を加工。人物を除去し、自然な範囲で明るさ・色調を調整）
- 高知県立高知城歴史博物館: `kochi-castle-history-museum.png`
- 高知県立坂本龍馬記念館: `sakamoto-ryoma-memorial-museum.png`
- 潮江天満宮: `shioe-tenmangu.png`

## 体験ページ用追加画像（2026-09-30）

- 仁淀川シーカヤック: `sea-kayak.jpg`
  - ユーザー提供の加工済み画像をサイト内アセットとして使用。
  - 上空から見下ろす構図。外部ホットリンクなし。

## グルメページ用追加画像（2026-09-30）

- 屋台安兵衛: `yasube.png`（ユーザー提供画像を加工）
- 橋本食堂: `hashimoto.png`（ユーザー提供画像を加工）
- 田中鮮魚店 漁師小屋: `tanaka.png`（ユーザー提供画像を加工。写っていた人物は架空の人物へ置換）
- 安芸しらす食堂 本店: `shirasu.png`（ユーザー提供画像を加工）
- 高知アイス売店 仁淀川カフェ: `ice.png`（ユーザー提供画像を加工。仁淀川を望む店内写真）
- 明神丸 本店: `myojinmaru.png`（ユーザー提供画像を加工）。掲載スポットを「明神丸 本店」へ変更し、専用写真として使用。
- 6点とも外部ホットリンクなし。サイト内アセットとして保管・使用。

## イベントページ用画像（2026-10-01）

- よさこい祭り: `event-yosakoi.png`（ユーザー保管のサイトデザイン画像から切り出し。イメージ写真として表示）
- Tシャツアート展: `event-tshirt-art.png`（同上）
- 高知城 花回廊: `event-hanakairou.png`（同上）
- 土佐の「おきゃく」: `event-okyaku.png`（同上）
- 大川村謝肉祭: `event-okawa.png`（同上）
- 高知城オータムフェスティバル: 既存の `kochi-castle.jpg` を会場イメージとして使用。
- 仁淀川 紙のこいのぼり: 既存の `course-niyodo-sup.png` を仁淀川イメージとして使用。
- イベント画像は実際の2026年開催記録写真と誤認されないよう、カード上に「イメージ写真」「会場イメージ」「仁淀川イメージ」を表示する。

## 高知城写真差し替え（2026-10-01）

- 高知城: `kochi-castle-new.png`（ユーザー提供画像を軽く加工。明るさ・コントラスト・色味・解像感を自然な範囲で調整）
- 高知城のランキング、観光一覧、詳細、歴史文化ページ、関連コース、イベント会場イメージなど、既存の高知城画像参照を新画像へ統一。
- 外部ホットリンクなし。サイト内アセットとして使用。

## テントサウナ・四国カルスト写真差し替え（2026-10-02）

- Niyodo Adventureのテントサウナ: `tent-sauna-niyodo.png`（ユーザー指定で作成・加工した白いテントサウナのイメージ画像）。スポット詳細、体験ページ、トップの体験カード、仁淀川アクティブコースで使用。
- 四国カルスト: `shikoku-karst.png`（ユーザー提供画像を軽く加工。風車とカルスト台地の景観）。スポット詳細、景色・名所、モデルコース、関連ヒーローで使用。
- 2点とも外部ホットリンクなし。 `kochi/assets/photos/` に同梱。

## 空と仁淀ブルーキャンプ1日コース写真（2026-10-02）

- `course-niyodo-sky-camp.png`（ユーザー提供画像）。パラグライダー、仁淀ブルー、キャンプのイメージをまとめたコラージュとして、モデルコース一覧・詳細・おすすめ表示に使用。

## 柏島・足摺 海の1泊2日コース写真（2026-10-02）

- `course-ocean-trip-collage.png`（ユーザー提供画像）。柏島の海、海鮮、夕日をまとめたコラージュとして、モデルコース一覧・詳細・関連導線に使用。

## 龍河洞写真差し替え（2026-10-02）

- 龍河洞: `ryugado-caving.png`（ユーザー提供画像）。ライトアップされた洞内とヘルメット姿の人物が写る写真として、龍河洞のランキング・一覧・詳細・関連コースで使用。

### 釣り・サーフィン追加（2026-10-02）

| 対象 | 画像 | 出典・撮影者 | 使用条件 |
|---|---|---|---|
| 生見サーフィンビーチ | ikumi-surf.jpg | Araiyasushige / Wikimedia Commons | CC0 |
| 入野海岸 | irino-surf.jpg | Ubuhouse / Wikimedia Commons | CC BY-SA 3.0 |
| 大岐海岸 | Wikimedia Commons original URL | Yobito KAYANUMA / Wikimedia Commons | CC BY-SA 3.0 |
| 竜串 船釣り体験 | tatsukushi-fishing.jpg（竜串海岸） | Reggaeman / Wikimedia Commons | CC BY-SA 3.0 |
| 仁淀川の釣り | niyodo-fishing.jpg（中仁淀橋付近） | 谷本 一郎 / Wikimedia Commons | CC BY-SA 4.0 |

須崎・富士ヶ浜 海釣り体験は、利用許諾を確認できる写真をまだ確保していないため写真未設定。別スポットの写真は流用しない。

- 鵜来島 釣り体験：uguru-fishing.jpg / ブルーノ・プラス / Wikimedia Commons / CC BY 4.0

### 漁業体験・ホエールウォッチング追加（2026-10-02）

- 大方ホエールウォッチング：`irino-surf.jpg` を黒潮町・入野海岸の海辺イメージとして使用。Ubuhouse / Wikimedia Commons / CC BY-SA 3.0。クジラそのものの写真ではない。
- 上ノ加江漁業体験：`kaminokae-fishery.jpg` を漁業体験イメージとして使用。Long (lTiga) Nguyen / Unsplash / Unsplash License。実際の上ノ加江で撮影された写真ではないため、イメージ写真として扱う。

### 動物園・ドルフィンセンター追加（2026-10-02）

- 高知県立のいち動物公園：`noichi-zoo.jpg`。Shoichi Masuhara / Wikimedia Commons / CC BY 2.0。実際の園内写真。
- 室戸ドルフィンセンター：`muroto-dolphin.jpg`。safaritravelplus / Wikimedia Commons / CC0。施設で撮影された写真ではないため、イルカ体験イメージとして扱う。

### 体験ページ追加（2026-10-02）

- フォレストアドベンチャー・高知：既存サイト資産 `hero-forest-adventure.png` を使用。
- NIYODO バギー体験：既存サイト資産 `hero-buggy.png` を使用。
- 吾川スカイパーク パラグライダー：既存サイト資産 `hero-paragliding.png` を使用。
- カツオの藁焼きタタキづくり体験：既存サイト資産 `course-katsuo-tataki.png` を使用。
- 紙漉き体験：`ino-papermaking.jpg`。Library of Congress由来の1772年の紙漉き版画 / Public Domain。現代のいの町紙の博物館の実写ではないため、紙漉きイメージとして扱う。
- 鳴子づくり体験：`yosakoi-naruko.jpg`。Mycomp / Wikimedia Commons / CC BY-SA 3.0。よさこいで使われる鳴子そのものの写真。

### 体験ページ追加 第2弾（2026-10-02）

- 土佐タタキ道場：既存サイト資産 `course-katsuo-tataki.png` を使用。
- FIELD KOCHI：`field-kochi.jpg`。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。和歌山県の里山写真のため、FIELD KOCHI現地写真ではなく里山体験イメージとして扱う。
- 龍河洞キャンドルづくり：`ryugado-candle.jpg`。Wellcome Library, London / Wikimedia Commons / CC BY 4.0。現代の38 phyto lab.の実写ではなくキャンドルづくりイメージとして扱う。
- 四万十川カヌー体験：`shimanto-canoe.jpg`。Cherrysherbet / Wikimedia Commons / CC BY-SA 3.0。四万十市西土佐で撮影された四万十川の実景。

### 体験ページ追加 第3弾（2026-10-02）

- 吉野川ラフティング：既存サイト資産 `hero-rafting.png` を使用。
- 高知ホースライディングクラブ：`kochi-horse-riding.jpg`。MIKI Yoshihito / Wikimedia Commons / CC BY 2.0。高知ホースライディングクラブの実写ではないため乗馬体験イメージとして扱う。
- 鵜来島シュノーケル：既存の `uguru-fishing.jpg` を鵜来島の海イメージとして再利用。ブルーノ・プラス / Wikimedia Commons / CC BY 4.0。
- 刃物鍛造体験：`sakoda-knife.jpg`。Tim Lively / Wikimedia Commons / CC BY-SA 3.0。迫田打刃物の実写ではなく鍛造刃物イメージとして扱う。
- 内原野陶芸・ガラス体験：`uchiharano-pottery.jpg`。Eman abdelkader12 / Wikimedia Commons / CC BY-SA 4.0。内原野陶芸館の実写ではなく陶芸体験イメージとして扱う。

### 体験ページ追加 第4弾（2026-10-02）

- TOSACO TAP STAND・醸造所：施設公式写真は転載条件未確認のため専用写真未設定。
- 高木酒造 酒蔵見学：施設公式写真は転載条件未確認のため専用写真未設定。
- こうち旅広場 レンタサイクル：既存サイト資産 `course-classic-bridge.png` を高知市街サイクリングのイメージとして使用。
- 龍馬の生まれたまち歩き〜土佐っ歩〜：既存サイト資産 `sakamoto-ryoma-memorial-museum.png` を龍馬ゆかりの高知を歩くイメージとして使用。

### 体験ページ追加 第5弾（2026-10-02）

- 室戸海洋深層水アクア・ファーム：既存の `muroto.jpg` を室戸エリアのイメージとして使用。Rsa / Wikimedia Commons / CC BY-SA 3.0。
- 室戸世界ジオパーク ガイドツアー：既存の `muroto.jpg` を使用。実際のガイドツアー中の写真ではないため室戸ジオパークのイメージとして扱う。
- 室戸世界ジオパーク 磯遊び体験：既存の `muroto.jpg` を使用。室戸岬の岩礁と海の実景。
- 室戸世界ジオパーク サイクリングツアー：既存の `muroto.jpg` を使用。サイクリング中の実写ではないため室戸の海岸景観イメージとして扱う。

### 体験ページ追加 第6弾（2026-10-02）

- 四万十川 SUP・カヌー（withRIVER）：既存の `shimanto-canoe.jpg` を四万十川エリアの実景として再利用。Cherrysherbet / Wikimedia Commons / CC BY-SA 3.0。
- アウトドア！ガルバンゾ：既存サイト資産 `hero-rafting.png` を吉野川リバーアクティビティのイメージとして使用。
- 津野茶 茶畑見学・お茶体験：既存の `field-kochi.jpg` を山間の里山イメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。津野町の実写ではないためイメージとして扱う。

### 体験ページ追加 第7弾（2026-10-02）

- 天日塩づくり体験（ソルティーブ）：既存の `irino-surf.jpg` を黒潮町の海イメージとして使用。Ubuhouse / Wikimedia Commons / CC BY-SA 3.0。施設実写ではない。
- 完全天日塩づくり体験（田野町）：既存の `muroto.jpg` を高知県東部の海岸イメージとして使用。Rsa / Wikimedia Commons / CC BY-SA 3.0。施設実写ではない。
- 土佐町 木組み・鍋敷きづくり体験：既存の `field-kochi.jpg` を山間の里山イメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。土佐町の実写ではない。
- 四万十川 伝統漁法体験：既存の `shimanto-canoe.jpg` を四万十川の実景として再利用。Cherrysherbet / Wikimedia Commons / CC BY-SA 3.0。

### 体験ページ追加 第8弾（2026-10-02）

- そば打ち体験（であいの里 蜷川）：既存の `field-kochi.jpg` を山里の食体験イメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。黒潮町蜷川の実写ではない。
- こんにゃく作り体験（燈ので家）：既存の `field-kochi.jpg` を山あいの農家体験イメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。燈ので家の実写ではない。
- 田舎こんにゃく体験（せいらんの里）：既存の `field-kochi.jpg` を山里体験イメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。せいらんの里の実写ではない。
- 紙漉き体験（土佐和紙工芸村「くらうど」）：既存の `ino-papermaking.jpg` を紙漉きイメージとして再利用。Library of Congress / Public Domain。現代の施設実写ではない。

### アクティビティ追加 第9弾（2026-10-02）

- 柏島 体験ダイビング（AQUAS）：既存の `kashiwajima.jpg` を柏島エリアの実景として再利用。Saigen Jiro / Wikimedia Commons / CC0。AQUASの体験中実写ではない。
- 竜串 体験ダイビング（竜串ダイビングセンター）：既存の `tatsukushi-fishing.jpg` を竜串海岸の実景として再利用。Reggaeman / Wikimedia Commons / CC BY-SA 3.0。ダイビング中の実写ではない。

### 体験ページ追加 第10弾（2026-10-02）

- 牧野公園ガイド：既存の `field-kochi.jpg` を里山イメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。佐川町・牧野公園の実写ではない。
- 牧野博士の聖地を歩く（南山麓コース）：既存の `field-kochi.jpg` を里山ウォーキングのイメージとして使用。実際のコース写真ではない。
- 桂浜散策ガイド：既存サイト資産 `sakamoto-ryoma-memorial-museum.png` を桂浜エリアのイメージとして使用。ガイド中の実写ではない。
- まきのガイドウォーク：既存サイト資産 `makino-botanical-garden.png` を牧野植物園のイメージとして使用。

### 体験ページ追加 第11弾（2026-10-02）

- 草木染め体験（四万十かわらっこ）：既存の `shimanto-canoe.jpg` を四万十川流域の自然イメージとして使用。Cherrysherbet / Wikimedia Commons / CC BY-SA 3.0。草木染め中の実写ではない。
- 農家民宿くろうさぎ 田舎暮らし体験：既存の `field-kochi.jpg` を山里・農村のイメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。三原村・宿の実写ではない。
- わら馬作り体験（すさきまちかどギャラリー）：既存の `yosakoi-naruko.jpg` を高知の伝統文化・手仕事イメージとして使用。Mycomp / Wikimedia Commons / CC BY-SA 3.0。わら馬の実写ではない。

### 体験・アクティビティ追加 第12弾（2026-10-02）

- 土佐国分寺 日本文化・瞑想体験：既存の `chikurinji.png` を寺院文化のイメージとして使用。土佐国分寺の実写ではない。
- 足摺秘境ガイド：既存の `ashizuri.jpg` を足摺岬の実景として使用。遊覧船・巨石群ガイド中の実写ではない。
- 三原村 スローサイクリング（今ちゃん出発）：既存の `field-kochi.jpg` を田園・山里イメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。三原村の実写ではない。
- 足摺半島ぐるっと一周 E-bikeガイドツアー：既存の `ashizuri.jpg` を足摺半島の実景として使用。サイクリング中の実写ではない。

### 体験・アクティビティ追加 第13弾（2026-10-02）

- 四万十天文台 天体観望会：既存の `course-classic-camping.png` を夜のアウトドアイメージとして使用。天文台の実写ではない。
- 竜串観光汽船 グラスボート：既存の `tatsukushi-fishing.jpg` を竜串海岸の実景として再利用。Reggaeman / Wikimedia Commons / CC BY-SA 3.0。グラスボート実写ではない。
- 見残し奇岩パークツアー＋グラスボート：同じく `tatsukushi-fishing.jpg` を竜串海岸の実景として使用。
- グラスボートゆうばり：既存の `kashiwajima.jpg` を柏島エリアの実景として再利用。Saigen Jiro / Wikimedia Commons / CC0。グラスボート実写ではない。

### 体験・アクティビティ追加 第14弾（2026-10-02）

- 高知市卸売市場 果物のセリ見学＋フルーツバスケット：既存の `field-kochi.jpg` を農産物・地域の暮らしイメージとして使用。実際の市場写真ではない。
- 佐田沈下橋 ガイドサイクリング：既存の `shimanto-canoe.jpg` を四万十川の自然イメージとして使用。実際のサイクリング写真ではない。
- 赤野獅子舞：既存の `yosakoi-naruko.jpg` を高知の伝統芸能イメージとして使用。獅子舞の実写ではない。
- 四万十 公設卸売市場 模擬競り＋おさかなランチ：既存の `course-ocean-seafood.png` を海鮮料理イメージとして使用。市場の実写ではない。
- 四万十川屋形船 水上カフェ：既存の `shimanto-canoe.jpg` を四万十川の実景イメージとして使用。屋形船の実写ではない。

### 体験追加 第15弾（2026-10-02）

- ものづくり体験（海洋堂Space Factoryなんこく）：既存の `field-kochi.jpg` を地域体験イメージとして使用。施設・ワークショップの実写ではない。
- 苔玉づくり体験（おおぶち自然村）：既存の `field-kochi.jpg` を里山・緑のイメージとして使用。苔玉づくりの実写ではない。
- 土佐塩の道ウォーク（FIELD KOCHI）：既存の `field-kochi.jpg` を山里ウォーキングのイメージとして使用。実際の塩の道・参加風景ではない。

### 体験・アクティビティ追加 第16弾（2026-10-02）

- 伝統の節納屋見学＆宗田節体験（たけまさ商店）：既存の `course-katsuo-tataki.png` を高知のかつお文化イメージとして使用。たけまさ商店・宗田節工場の実写ではない。
- 土佐清張紙 工房見学＋クラフト体験：既存の `ino-papermaking.jpg` を和紙づくりの歴史イメージとして使用。Library of Congress / Public Domain。尾崎製紙所の実写ではない。
- 魚梁瀬森林鉄道跡とゆずロード E-bikeツアー：既存の `field-kochi.jpg` を中山間地域のイメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。実際のコース・E-bikeの実写ではない。
- 内原野陶芸館は既存の `uchiharano-pottery.jpg` と既存ページを継続使用。2026-10-02に現行情報を再確認し、重複ページは作成しない。

### 体験追加 第17弾（2026-10-02）

- 吉野川源流森林軌道ウォーク：既存の `hero-forest-adventure.png` を森林歩きのイメージとして使用。実際の森林軌道ウォークの写真ではない。
- まきの宿 いざなぎ流・古民家宿泊体験：既存の `field-kochi.jpg` を物部の山里・暮らしイメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。まきの宿の実写ではない。
- 四万十ヤイロチョウの森と森林鉄道遺構ウォーク：既存の `hero-forest-adventure.png` を森林自然観察のイメージとして使用。ヤイロチョウ・現地ツアーの実写ではない。
- 四万十のレンタサイクル＋メガSUPコーヒーは、2026-10-02時点で現行の予約可能プログラムを確認できず、過去のコンテスト受賞企画としてのみ確認できたため掲載見送り。

### 体験追加 第18弾（2026-10-02）

- 五感で感じる しらす漁師ツアー：既存の `shirasu.png` を安芸のしらす文化イメージとして使用。実際の2026年ツアー写真ではない。
- コスプレで巡る レトロな街 いの町 フォトツアー：既存の `field-kochi.jpg` を地域風景イメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。コスプレ撮影の実写ではない。
- 着物で楽しむ 料亭濱長お座敷遊び体験：既存の `event-yosakoi.png` を高知の伝統文化イメージとして使用。濱長・着物・芸妓の実写ではない。
- 半平太・はりまや橋コース：既存の `sakamoto-ryoma-memorial-museum.png` を幕末の土佐イメージとして使用。コース上の実写ではない。

### 体験追加 第19弾（2026-10-02）

- 浦ノ内湾 アカメ釣り体験：既存の `niyodo-fishing.jpg` を釣り体験イメージとして使用。浦ノ内湾・アカメの実写ではない。
- ごめん・なはり線 絶景フルーツ列車：既存の `field-kochi.jpg` を高知東部の風景イメージとして使用。Indiana jo / Wikimedia Commons / CC BY-SA 4.0。列車の実写ではない。
- 中土佐町久礼 漁師町フルコース：既存の `course-katsuo-tataki.png` をカツオ文化イメージとして使用。実際の競り・製塩・藁焼きツアーの実写ではない。
- 弁天座 芝居小屋バックヤード見学＆体験ツアー：既存の `event-yosakoi.png` を高知の舞台文化イメージとして使用。弁天座の実写ではない。

### 体験追加 第20弾（2026-10-02）

- 津野町 茶畑ウォーキング＋茶摘み＋田舎ごはん：既存の `field-kochi.jpg` を茶畑・里山イメージとして使用。実際の茶摘みツアー写真ではない。
- 霧山茶園 ほうじ茶焙煎＋和紙茶缶づくり：既存の `field-kochi.jpg` を茶畑・里山イメージとして使用。霧山茶園・焙煎体験の実写ではない。
- 梼原 本格絵付け体験：既存の `yusuhara.jpg` を梼原町の地域イメージとして使用。実際の絵付け体験・遊美庵の実写ではない。
- 英語でHAIKU in 土佐山：既存の `field-kochi.jpg` を土佐山の里山イメージとして使用。オーベルジュ土佐山・俳句体験の実写ではない。

### 体験追加 第21弾（2026-10-02）

- 朝の伊尾木洞探検＋ぢばさん市場ツアー：既存の `iokido.jpg` を伊尾木洞の実景として使用。市場部分の実写ではない。
- 予土線＋自転車＋ラフティングで巡る四万十川：既存の `hero-rafting.png` を四万十川ラフティングのイメージとして使用。予土線・サイクリング部分の実写ではない。
- 清水さば漁港ツアー＋漁師町食べ歩き：既存の `course-ocean-seafood.png` を魚食文化のイメージとして使用。清水さば・市場の実写ではない。
- 黒潮町 渚のアーシング体験 1泊2日：既存の `irino-surf.jpg` を黒潮町・入野海岸の海辺イメージとして使用。宿・アーシング・サウナの実写ではない。

### 体験追加 第22弾（2026-10-02）

- 仁淀ブルーを眺めながら水上整体：既存の `course-niyodo-sup.png` を仁淀川の水辺イメージとして使用。水上整体の実写ではない。
- 岩屋川渓谷ハイキング＋郷土茶菓いりもち：既存の `hero-forest-adventure.png` を渓谷・森林歩きのイメージとして使用。岩屋川渓谷・いりもちの実写ではない。
- 四万十川 漁師体験＋幻想ホタル遊覧ツアー：既存の `shimanto-canoe.jpg` を四万十川の水辺イメージとして使用。ホタル・漁師体験・BBQの実写ではない。
- 四万十川 伝統漁法体験は既存ページを維持し、2026-10-02に現行の料金・連絡先・予約締切情報へ更新。重複ページは作成しない。

### 体験追加 第23弾（2026-10-02）

- 紅茶農家で国産紅茶6品種テイスティング＋スイーツ：既存の `field-kochi.jpg` を佐川町の茶畑・里山イメージとして使用。明郷園・テイスティングの実写ではない。
- 仁淀ブルー絶景アフタヌーンティー：既存の `course-niyodo-sup.png` を仁淀川の水辺イメージとして使用。池川茶園・アフタヌーンティーの実写ではない。
- Farm-to-table ビーガン和食＆農園体験：既存の `field-kochi.jpg` を本山町の農園・里山イメージとして使用。めぐみめぐる農園・料理の実写ではない。
- 汗見川 清流E-bikeサイクリング：既存の `hero-forest-adventure.png` を山間部アウトドアイメージとして使用。汗見川・E-bikeの実写ではない。

### 体験追加 第24弾（2026-10-02）

- 日本唯一のもくめん工場見学＋クラフト体験：既存の `hero-forest-adventure.png` を木材・ものづくりイメージとして使用。戸田商行工場・クラフトの実写ではない。
- 大月満喫ツアー イカ釣り体験：既存の `uguru-fishing.jpg` を高知西部の海釣りイメージとして使用。ケンサキイカ・大月町の実際の船の写真ではない。
- ヤ・シィパーク SUP＆カヤック体験：既存の `ikumi-surf.jpg` を高知東部の海イメージとして使用。ヤ・シィパーク・SUP・カヤックの実写ではない。
- 市場直送カツオ 解体ショー＋藁焼き3種食べ比べ：既存の `course-katsuo-tataki.png` をカツオ藁焼きイメージとして使用。実際の市場・解体ショーの実写ではない。

### 写真差し替え優先順位（2026-10-02 最終チェック）

#### 優先度A：内容とのズレが大きく、最優先で実写または場所に近い写真へ差し替える
1. `gomen-nahari-fruit-train` ごめん・なはり線 絶景フルーツ列車 — 現在は `field-kochi.jpg`。列車・車窓・フルーツが写っていない。
2. `bentenza-backstage-experience` 弁天座 芝居小屋バックヤード見学＆体験ツアー — 現在はよさこい系画像。弁天座の建物・舞台写真を優先。
3. `ogata-whale` 大方ホエールウォッチング — 現在は入野海岸。クジラ・観察船の写真を優先。
4. `ino-papermaking` いの町紙の博物館 紙漉き体験 — 現在は歴史版画。現代の紙漉き体験・施設写真を優先。
5. `niyodo-water-seitai` 仁淀ブルーを眺めながら水上整体 — 現在はSUPイメージ。水上整体の内容が伝わる写真を優先。
6. `ikegawa-afternoon-tea` 仁淀ブルー絶景アフタヌーンティー — 現在は仁淀川イメージ。お茶・スイーツ・眺望が分かる写真を優先。
7. `tosa-mokumen-factory` 日本唯一のもくめん工場見学＋クラフト体験 — 現在は森林アクティビティ画像。工場・もくめん・クラフト写真を優先。
8. `kochi-market-fruit-basket` 高知市卸売市場 果物のセリ見学＋フルーツバスケット — 現在は里山画像。市場・果物写真を優先。
9. `kaiyodo-nankoku-workshop` 海洋堂Space Factoryなんこく ものづくり体験 — 現在は里山画像。施設・フィギュア・ワークショップ写真を優先。
10. `kochi-kimono-ozashiki` 着物で楽しむ 料亭濱長お座敷遊び体験 — 現在はよさこい系画像。着物・料亭・お座敷文化が分かる写真を優先。
11. `shimizu-katsuo-show` 市場直送カツオ 解体ショー＋藁焼き3種食べ比べ — 現在は汎用カツオ画像。市場・解体・藁焼きの実写を優先。
12. `yodo-line-cycle-rafting` 予土線＋自転車＋ラフティングで巡る四万十川 — 現在はラフティングのみ。予土線・自転車も伝わる写真を優先。

#### 優先度B：同じ汎用写真の再利用が多く、順次差し替える
- `field-kochi.jpg` は23ページで使用。茶畑、農園、工場、市場、宿泊、サイクリング等で内容差が大きいため、上記Aの後に個別写真へ置換する。
- `shimanto-canoe.jpg` は7ページ、`hero-forest-adventure.png` は6ページ、`muroto.jpg` は6ページ、`course-katsuo-tataki.png` は5ページで再利用。
- 実景が同じ地域で内容も近い再利用（柏島・足摺・室戸など）は優先度を下げ、体験内容がまったく異なる再利用を先に直す。

#### 優先度C：現地実景を使っており、体験中の写真ではないが誤解が少ない
- 柏島ダイビング、竜串グラスボート、足摺E-bike、伊尾木洞朝ツアーなど。地域の実景が一致しているため、A/B完了後に対応する。

### 写真差し替え実施（2026-10-03）

- `gomen-nahari-fruit-train`：`field-kochi.jpg` から、ごめん・なはり線を走る土佐くろしお鉄道9640形の実写 `gomen-nahari-train.jpg` へ差し替え。MaedaAkihiko / Wikimedia Commons / CC0。
- `ino-papermaking`：歴史版画から、いの町紙の博物館の実際の外観 `ino-paper-museum.jpg` へ差し替え。At by At / Wikimedia Commons / CC BY-SA 3.0。
- `ogata-whale`：入野海岸のみの写真から、ニタリクジラの実写 `ogata-whale-brydes.jpg` へ差し替え。Chainfoto / Wikimedia Commons / CC BY 4.0。撮影地はタイ湾のため、高知現地写真ではなく「ニタリクジラのイメージ」として扱う。
- `bentenza-backstage-experience`：再利用条件を確認できる弁天座実写が見つからなかったため今回は未変更。権利確認できる写真が見つかるまで既存イメージを維持する。

### 写真差し替え実施 第2弾（2026-10-03）

- `niyodo-water-seitai`：汎用SUP画像から、いの町の仁淀川実景 `niyodo-water-seitai-river.jpg` へ差し替え。Kuruman / Wikimedia Commons / CC BY 2.0。
- `ikegawa-afternoon-tea`：汎用仁淀川画像から、仁淀川町・池川地区の実景 `ikegawa-area.jpg` へ差し替え。Sanjo / Wikimedia Commons / CC BY-SA 4.0。アフタヌーンティーそのものの実写ではない。
- `tosa-mokumen-factory`：森林アクティビティ画像から、木毛（wood wool）の実物 `tosa-mokumen-material.jpg` へ差し替え。Meanwell Packaging / Wikimedia Commons / CC BY 2.0。戸田商行の工場実写ではない。
- `kaiyodo-nankoku-workshop`：里山画像から、海洋堂のフィギュア展示 `kaiyodo-figure-display.jpg` へ差し替え。LittleT889 / Wikimedia Commons / CC BY 4.0。大阪の海洋堂施設で撮影された写真のため、Space Factoryなんこくの実写ではなく海洋堂フィギュア展示イメージとして扱う。

### 写真差し替え実施 第3弾（2026-10-03）

- `kochi-market-fruit-basket`：里山画像から、日本の中央卸売市場で行われる実際の青果セリ `kochi-market-auction.jpg` へ差し替え。慈姑鑑真 / Wikimedia Commons / CC BY-SA 4.0。撮影地は福岡市中央卸売市場のため、高知市卸売市場の実写ではなく「青果セリのイメージ」として扱う。
- `kochi-kimono-ozashiki`：よさこい系画像から、実際のお座敷遊び「金毘羅船々」 `kochi-ozashiki-asobi.jpg` へ差し替え。Japanexperterna.se / Wikimedia Commons / CC BY-SA 3.0。撮影地は京都のため、料亭濱長の実写ではなくお座敷遊びイメージとして扱う。
- `shimizu-katsuo-show`：汎用カツオ画像から、高知市で撮影されたカツオのたたき実写 `shimizu-katsuo-kochi.jpg` へ差し替え。ノボホショコロトソ / Wikimedia Commons / CC BY 4.0。土佐清水の市場・解体ショーそのものの実写ではない。
- `yodo-line-cycle-rafting`：ラフティングのみの画像から、四万十川沿いを走る予土線の実景 `yodo-line-shimanto.jpg` へ差し替え。Takuma-sa / Wikimedia Commons / CC BY-SA 3.0。自転車・ラフティング部分は写っていないが、ツアーの主要要素である予土線と四万十川を実景で示す。
- `bentenza-backstage-experience`：権利確認できる弁天座実写を確認できなかったため今回も未変更。

### 写真差し替え実施 第4弾（2026-10-03）

- `sakawa-black-tea-tasting`：汎用里山画像から、佐川町の虚空蔵山周辺と田園風景 `sakawa-black-tea-area.jpg` へ差し替え。Navian / Wikimedia Commons / Public Domain。紅茶農園・テイスティングそのものの実写ではないが、実際の佐川町の風景。
- `motoyama-vegan-farm`：汎用里山画像から、本山町の白髪山と棚田が写る `motoyama-vegan-area.jpg` へ差し替え。As6022014 / Wikimedia Commons / Public Domain。農園・料理そのものの実写ではないが、実際の本山町の山里風景。
- `asemikawa-ebike` と `iwayagawa-irimochi-hike` は、場所一致と再利用条件を両方確認できる適切な写真がまだ不足しているため今回は未変更。

### 写真差し替え実施 第5弾（2026-10-03）

- `mihara-slow-cycling`：汎用里山画像から、実際の三原村・星ヶ丘公園 `mihara-hoshigaoka.jpg` へ差し替え。Lumi iori / Wikimedia Commons / CC BY-SA 4.0。サイクリング中の実写ではないが、開催地域の実景。
- `mihara-rural-stay`：汎用里山画像から、実際の三原村・星ヶ丘公園 `mihara-hoshigaoka.jpg` へ差し替え。Lumi iori / Wikimedia Commons / CC BY-SA 4.0。農家民宿そのものの実写ではないが、開催地域の実景。
- `asemikawa-ebike`、`iwayagawa-irimochi-hike`、`shimanto-yairocho-walk`、`yoshino-headwaters-track-walk` は、現地写真は確認できたものの転載・再利用条件まで確定できないものが中心だったため今回は未変更。

### 写真差し替え実施 第6弾（2026-10-03）

- `tsuno-tea-fullcourse`：汎用里山画像から、実際の津野町・四万十川源流部 `tsuno-source-river.jpg` へ差し替え。Asset utilitist / Wikimedia Commons / CC0。茶摘みそのものの実写ではないが、開催地域の実景。
- `tsuno-tea-field`：汎用里山画像から、実際の津野町・四万十川源流部 `tsuno-source-river.jpg` へ差し替え。Asset utilitist / Wikimedia Commons / CC0。茶畑そのものの実写ではないが、開催地域の実景。
- `yusuhara-china-paint`：既存の梼原イメージ画像から、実際の梼原町梼原の町並み `yusuhara-town.jpg` へ差し替え。osami / Wikimedia Commons / Public Domain。絵付け体験そのものの実写ではない。
- `kiriyama-roasting-teacan` と `tosayama-haiku` は、開催地・内容・権利条件を同時に満たす写真が不足しているため今回は未変更。

### 写真差し替え実施 第7弾（2026-10-03）

- `ino-cosplay-photo-tour`：汎用里山画像から、実際のいの町・JR伊野駅 `ino-photo-tour.jpg` へ差し替え。Rsa / Wikimedia Commons / CC BY-SA 3.0。コスプレ撮影そのものの実写ではないが、集合地・開催地域の実景。
- `monobe-izanagi-stay`：汎用里山画像から、実際の香美市物部町大栃 `monobe-stay-area.jpg` へ差し替え。r18 INO (PACHIMO) / Wikimedia Commons / CC BY 3.0。まきの宿そのものの実写ではないが、開催地域の実景。
- `kiriyama-roasting-teacan` と `tosayama-haiku` は、今回は開催地・内容・権利条件を同時に満たす十分な写真が見つからず未変更。

### 写真差し替え実施 第8弾（2026-10-03）

- `umaji-yuzu-forest-ebike`：汎用里山画像から、実際の馬路村・馬路森林鉄道 馬路温泉前駅 `umaji-forest-railway.jpg` へ差し替え。221.20 / Wikimedia Commons / Public Domain。E-bike走行中の実写ではないが、ツアー主要テーマの森林鉄道と開催地域が一致。
- `kiriyama-roasting-teacan`、`tosayama-haiku`、`obuchi-kokedama` は、今回は内容・開催地・権利条件を同時に満たす写真が不足しているため未変更。

### 写真差し替え実施 第9弾（2026-10-03）

- `sakawa-makino-park-guide`：汎用里山画像から、実際の佐川町・牧野公園 `sakawa-makino-park.jpg` へ差し替え。アラツク / Wikimedia Commons / CC BY-SA 4.0。
- `sakawa-makino-sacred-walk`：汎用里山画像から、実際の佐川町・牧野公園 `sakawa-makino-park.jpg` へ差し替え。アラツク / Wikimedia Commons / CC BY-SA 4.0。南山麓コース全行程の実写ではないが、主要テーマ・開催地域が一致。

### 写真差し替え実施 第10弾（2026-10-03）

- `kuroshio-soba`：汎用里山画像から、そば打ちの実際の工程（そば生地を切る様子）`kuroshio-soba-making.jpg` へ差し替え。Chris 73 / Wikimedia Commons / CC BY-SA 3.0。黒潮町・であいの里蜷川の実写ではなく、そば打ち工程のイメージとして扱う。
- `obuchi-kokedama`：汎用里山画像から、苔玉の実物 `obuchi-kokedama.jpg` へ差し替え。TRIAN FITRIYANI / Wikimedia Commons / CC BY 4.0。おおぶち自然村の実写ではなく、体験内容を示す苔玉イメージとして扱う。
- `tosacho-woodwork`：汎用里山画像から、日本の指物の木組み接合 `tosacho-woodwork.jpg` へ差し替え。Andy Li / Wikimedia Commons / CC0。土佐町の実写ではなく、木組み・木工体験の内容イメージとして扱う。

### 写真差し替え実施 第11弾（2026-10-03）

- `hinodeya-konnyaku`：汎用里山画像から、ブロック状のこんにゃく実物 `hinodeya-konnyaku.jpg` へ差し替え。Fumikas Sagisavas / Wikimedia Commons / CC0。燈ので家の実写ではなく、こんにゃく作りの完成品イメージとして扱う。
- `seiran-konnyaku`：汎用里山画像から、刺身こんにゃく実物 `seiran-konnyaku.jpg` へ差し替え。Ocdp / Wikimedia Commons / CC0。せいらんの里の実写ではなく、体験後に味わう刺身こんにゃくのイメージとして扱う。
- `kiriyama-roasting-teacan`：汎用里山画像から、焙煎済みほうじ茶の茶葉 `kiriyama-hojicha.jpg` へ差し替え。Green / Wikimedia Commons / Public Domain。霧山茶園や焙煎作業そのものの実写ではなく、体験内容を示すほうじ茶イメージとして扱う。
- `tosayama-haiku` と `tosa-shio-no-michi-walk` は、開催地・体験内容・再利用条件を同時に満たす写真がまだ不足しているため今回は未変更。

### 写真差し替え実施 第12弾（2026-10-03）

- `tosa-shio-no-michi-walk`：汎用里山画像から、香美市物部町の「塩の道 登り口」実景 `tosa-shio-no-michi.jpg` へ差し替え。r18 INO (PACHIMO) / Wikimedia Commons / CC BY 3.0。開催地・体験テーマとも一致。
- `akano-shishimai`：よさこい鳴子画像から、日本の獅子舞実演 `akano-shishimai.jpg` へ差し替え。Takumi pandagraph / Wikimedia Commons / CC BY-SA 4.0。赤野・大元神社の実写ではないが、体験内容と一致する獅子舞イメージとして扱う。
- `susaki-warauma`：よさこい鳴子画像から、藁で作られた日本のわら馬 `susaki-warauma.jpg` へ差し替え。Yanajin33 / Wikimedia Commons / CC BY-SA 3.0。須崎の実作例ではないが、制作物そのものが分かるイメージとして扱う。
- `tosayama-haiku` は土佐山の現地画像候補を再確認したが、俳句・里山散策・会席の内容まで自然に伝えられる再利用可写真が不足しているため今回は未変更。

### 写真差し替え実施 第13弾（2026-10-03）

- `shimanto-botanical-dye`：四万十川の汎用風景から、天然染料の素材と染色布が分かる `shimanto-botanical-dye.jpg` へ差し替え。SEN Heritage Looms - Sophia Tsourinaki / Wikimedia Commons / CC BY-SA 4.0。四万十かわらっこの実写ではないが、体験内容との一致度を優先。
- `muroto-geo-guide`：室戸岬の汎用海岸写真から、実際の室戸世界ジオパークセンター `muroto-geopark-center.jpg` へ差し替え。Dokudami / Wikimedia Commons / CC BY-SA 4.0。集合・案内拠点の実景として使用。

### 写真差し替え実施 第14弾（2026-10-03）

- `shimanto-sada-cycling`：四万十川の汎用風景から、実際の佐田沈下橋 `shimanto-sada-cycling.jpg` へ差し替え。四万十人 / Wikimedia Commons / CC BY-SA 3.0。ツアー主要立ち寄り地と一致。
- `shimanto-yakatabune-cafe`：四万十川の汎用風景から、日本の屋根付き遊覧船 `shimanto-yakatabune-cafe.jpg` へ差し替え。ブルーノ・プラス / Wikimedia Commons / CC BY 4.0。四万十川・屋形船なっとくの実写ではなく、屋形船タイプのイメージとして扱う。
- `shimanto-traditional-fishing`：四万十川の汎用風景から、投網を使った伝統漁の実演 `shimanto-traditional-fishing.jpg` へ差し替え。Zaheed Sarwer Khan / Wikimedia Commons / CC BY 4.0。四万十川の実写ではないが、体験内容との一致度を優先。
