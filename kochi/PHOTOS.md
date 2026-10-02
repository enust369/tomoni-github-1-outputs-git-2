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
