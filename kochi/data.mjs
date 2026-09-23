import {photos} from './photos.mjs';
export const areas={kochi_city:'高知市内',east:'東部',west:'西部',north_niyodo:'北部・仁淀川'};
export const categories={sightseeing:'観光',gourmet:'グルメ',cycling:'サイクリング',camp:'キャンプ',onsen:'温泉',michinoeki:'道の駅',stay:'宿泊',fishing:'釣り',surfing:'サーフィン',activity:'アクティビティ'};
export const themes=['王道','グルメ','子連れ','カップル','絶景','ドライブ','アクティブ','雨の日'];
export const filters={sightseeing:['絶景','歴史','子連れ','雨の日','デート','定番','穴場'],gourmet:['ひろめ市場','カツオ','郷土料理','居酒屋','ラーメン','ランチ','スイーツ','朝ごはん','おみやげ'],activity:['川あそび','海あそび','釣り・漁業体験','空・山','動物・自然観察','文化・ものづくり体験']};
const rows=[
['ryugado','龍河洞','sightseeing','east','香美市','雨の日,子連れ,定番','地底に広がる、もうひとつの高知。'],
['nikobuchi','にこ淵','sightseeing','north_niyodo','いの町','絶景,定番','心をほどく、仁淀ブルー。'],
['iokido','伊尾木洞','sightseeing','east','安芸市','絶景,穴場','緑に包まれた、神秘の散歩道。'],
['kochi-castle','高知城','sightseeing','kochi_city','高知市','歴史,定番','城下町の時間を、ゆっくり歩く。'],
['kashiwajima','柏島','sightseeing','west','大月町','絶景,デート','透きとおる海に、会いにいく。'],
['yasui','安居渓谷','sightseeing','north_niyodo','仁淀川町','絶景,穴場','渓谷の青と、深い緑。'],
['nakatsu','中津渓谷','sightseeing','north_niyodo','仁淀川町','絶景','水の音を道しるべに。'],
['monet','北川村「モネの庭」マルモッタン','sightseeing','east','北川村','デート,子連れ','花と光をめぐる庭時間。'],
['muroto','室戸岬','sightseeing','east','室戸市','絶景','太平洋を望む岬へ。'],
['karst','四国カルスト','sightseeing','west','津野町','絶景','空に近い、ドライブへ。'],
['yusuhara','梼原','sightseeing','west','梼原町','歴史','山あいの町を訪ねて。'],
['ashizuri','足摺岬','sightseeing','west','土佐清水市','絶景','海の向こうに思いを馳せて。'],
['myojinmaru','明神丸 ひろめ市場店','gourmet','kochi_city','高知市','ひろめ市場,カツオ,ランチ','高知らしい一皿から、旅が始まる。'],
['yasube','屋台安兵衛','gourmet','kochi_city','高知市','居酒屋','夜の高知に寄り道。'],
['hashimoto','橋本食堂','gourmet','west','須崎市','ラーメン,ランチ','あたたかな一杯を求めて。'],
['tanaka','田中鮮魚店 漁師小屋','gourmet','west','中土佐町','カツオ,ランチ','港町で味わう、海の恵み。'],
['shirasu','安芸しらす食堂 本店','gourmet','east','安芸市','ランチ','東部の旅に、おいしいひと休み。'],
['ice','高知アイス売店 仁淀川カフェ','gourmet','north_niyodo','いの町','スイーツ','川を眺める、カフェ時間。'],
['kayak','仁淀川シーカヤック','activity','north_niyodo','確認中','川あそび','水面から出会う、仁淀川。'],
['sauna','Niyodo Adventureのテントサウナ','activity','north_niyodo','確認中','川あそび','自然を感じる、特別な時間。']];
const spotInfo={
  ryugado:{address:'高知県香美市土佐山田町逆川1424',phone:'0887-53-2144',official_url:'https://ryugadou.or.jp/',parking_text:'駐車場約700台',access:'高知自動車道南国ICから車。土佐山田駅からバス。',last_verified_at:'2026-09-23'},
  nikobuchi:{address:'高知県吾川郡いの町清水上分',official_url:'https://nikobuchi.inofan.jp/site/access.html',parking_text:'指定駐車場あり。満車時は臨時駐車場等の案内を確認。',access:'伊野ICから車で約60分。JR伊野駅からバス利用後、徒歩約20〜30分。',last_verified_at:'2026-09-23'},
  iokido:{address:'高知県安芸市伊尾木117',price_text:'無料',phone:'0887-34-8344（安芸観光情報センター）',official_url:'https://kochi-tabi.jp/search_spot.html?id=544',parking_text:'無料駐車場あり',access:'ごめん・なはり線伊尾木駅から徒歩約7分。南国ICから車で約45分。',last_verified_at:'2026-09-23'},
  'kochi-castle':{address:'高知県高知市丸ノ内1丁目2番1号',opening_hours:'9:00〜17:00（最終入館16:30）',closed_days:'12月26日〜1月1日',price_text:'18歳以上500円、18歳未満無料',phone:'088-824-5701（高知城管理事務所）',official_url:'https://kochipark.jp/kochijyo/',parking_text:'高知公園駐車場65台。7:30〜18:30、有料。',access:'高知駅から路面電車・バスで約15分。',last_verified_at:'2026-09-23'},
  kashiwajima:{address:'高知県幡多郡大月町柏島',closed_days:'島全体のため設定なし',price_text:'入域料なし',official_url:'https://www.town.otsuki.kochi.jp/life/dtl.php?hdnKey=1782',parking_text:'観光案内所駐車場は7〜9月のみ案内。171台、1日500円。年間常設情報としては未確認。',access:'大月町中心部から県道43号等を経由。',last_verified_at:'2026-09-23'},
  yasui:{address:'高知県吾川郡仁淀川町大屋',price_text:'無料',phone:'0889-35-1333（仁淀川町観光協会）',official_url:'https://kochi-tabi.jp/search_spot.html?id=693',parking_text:'無料駐車場約50台',access:'伊野ICから車で約65分。県道362号は狭い山道。',last_verified_at:'2026-09-23'},
  nakatsu:{address:'高知県吾川郡仁淀川町名野川',price_text:'無料',phone:'0889-35-1083（仁淀川町産業建設課）',official_url:'https://kochi-tabi.jp/search_spot.html?id=766',parking_text:'無料駐車場、普通車約30台',access:'伊野ICから車で約1時間。',last_verified_at:'2026-09-23'},
  monet:{address:'高知県安芸郡北川村野友甲1100',opening_hours:'9:00〜17:00（最終入園16:30）',closed_days:'6〜10月の第1・第3水曜日、12〜2月（冬期休園）',price_text:'大人1,000円、小中学生500円、6歳未満無料',phone:'0887-32-1233',official_url:'https://www.kjmonet.jp/',parking_text:'無料。普通車約100台、大型バス6台。',access:'奈半利駅から北川村営バス。奈半利町から車で約5分。',last_verified_at:'2026-09-23'},
  muroto:{address:'高知県室戸市室戸岬町',official_url:'https://www.muroto-kankou.com/access/',access:'高知市から国道55号で約2時間。奈半利駅からバスで約60分。',last_verified_at:'2026-09-23'},
  karst:{official_url:'https://town.kochi-tsuno.lg.jp/tsunobura/asobu/',access:'地点により異なる。津野町側は町内から車で約35分。',last_verified_at:'2026-09-23'},
  ashizuri:{address:'高知県土佐清水市足摺岬',price_text:'無料',phone:'0880-82-3155（土佐清水市観光協会）',official_url:'https://kochi-tabi.jp/search_spot.html?ID=712',parking_text:'無料。岬先端20台、第一115台、東50台。',access:'中村駅から車で約1時間。バス停「足摺岬」下車すぐ。',last_verified_at:'2026-09-23'},
  myojinmaru:{address:'高知県高知市帯屋町2-3-1 ひろめ市場内',opening_hours:'月〜土11:00〜21:00、日10:00〜20:00',closed_days:'ひろめ市場休館日に準ずる。店舗別休業日は公式告知を確認。',official_url:'https://shop.myojinmaru.jp/shop/hiromeichiba/',parking_text:'駐車場あり。料金は未確認。',access:'とさでん大橋通駅から徒歩1分。高知駅から徒歩約15分。',last_verified_at:'2026-09-23'},
  yasube:{address:'高知県高知市廿代町4-19',opening_hours:'19:00〜翌3:00',closed_days:'日曜日',phone:'088-873-2773',official_url:'https://www.mfc-group.jp/yasube/shop.html',parking_text:'専用駐車場なし',access:'高知駅から徒歩約10分。蓮池町通停留場から徒歩約3分。',last_verified_at:'2026-09-23'},
  hashimoto:{address:'高知県須崎市横町4-19',opening_hours:'11:00〜14:00（受付13:50まで）',phone:'0889-42-2201',parking_text:'駐車場あり',last_verified_at:'2026-09-23'},
  tanaka:{address:'高知県高岡郡中土佐町久礼6382',phone:'0889-52-2729',official_url:'https://www.tanakatuo.com/',last_verified_at:'2026-09-23'},
  shirasu:{address:'高知県安芸市西浜3411-46',opening_hours:'11:00〜15:30（ラストオーダー）',closed_days:'木曜日・第1火曜日・年末年始',phone:'0887-34-8810',official_url:'https://akisuisan.com/restaurant/',parking_text:'駐車場あり',access:'南国ICから車で約40分。',last_verified_at:'2026-09-23'},
  ice:{address:'高知県吾川郡いの町柳瀬上分807-1',opening_hours:'平日11:00〜17:00（LO16:30）、土日祝等10:30〜17:00',closed_days:'第2・第4月曜日（7・8月除く）、年末年始。祝日の場合は翌火曜。',phone:'090-3787-8511',official_url:'https://www.kochi-ice.com/stores/',parking_text:'駐車場あり',access:'JR伊野駅から車で約25分。',last_verified_at:'2026-09-23'},
  sauna:{address:'高知県吾川郡仁淀川町高瀬3869',price_text:'1グループ10,000円〜（6時間レンタル）',phone:'080-5026-3288',official_url:'https://www.niyodoadventure.com/ja/river-sauna-tent',access:'高知市から車で約1時間30分。',last_verified_at:'2026-09-23'}
};
const rank={};
export const spots=rows.map(([slug,name,category,area,municipality,tags,catchphrase],i)=>({id:`00000000-0000-4000-8000-${String(i+1).padStart(12,'0')}`,slug,name,category,area,municipality,tags:tags.split(','),catchphrase,initial_rank:rank[category]=(rank[category]||0)+1,recommend_count:0,is_published:true,is_demo:true,photo:photos[slug]||null,main_image_url:photos[slug]?.src||'',description:'初期掲載候補です。営業時間・料金などは、公式情報の確認後に掲載します。',created_at:`2026-09-${String(i+1).padStart(2,'0')}T00:00:00Z`,...(spotInfo[slug]||{})}));
const courseRows=[
['kochi-classic','高知市内 王道1日コース','kochi_city','王道','1日',['kochi-castle','myojinmaru','yasube']],
['niyodo-classic','仁淀ブルー 王道1日コース','north_niyodo','絶景','1日',['nikobuchi','yasui','ice','nakatsu']],
['niyodo-active','仁淀川 アクティブ満喫1日コース','north_niyodo','アクティブ','1日',['kayak','sauna','ice','nakatsu']],
['east-drive','東部絶景＆しらすグルメ1日コース','east','グルメ','1日',['shirasu','iokido','monet','muroto']],
['ocean-trip','柏島・足摺 海の1泊2日コース','west','カップル','1泊2日',['kashiwajima','ashizuri']],
['karst-drive','四国カルスト・梼原 絶景ドライブ','west','ドライブ','1日',['karst','yusuhara']],
['kochi-gourmet','高知市内 グルメ満喫1日コース','kochi_city','グルメ','1日',['myojinmaru','yasube']],
['kami-konan','龍河洞・香美香南 1日コース','east','雨の日','1日',['ryugado']],
['family','高知 子連れ1日コース','kochi_city','子連れ','1日',['kochi-castle','myojinmaru']],
['three-days','高知満喫2泊3日コース','north_niyodo','王道','2泊3日',['kochi-castle','nikobuchi','iokido']]];
export const courses=courseRows.map(([slug,name,area,theme,duration,stops],i)=>({slug,name,area,theme,duration,stops,initial_rank:i+1,transport:'車＋徒歩',season:'季節・天候に応じて',audience:theme==='子連れ'?'家族':theme==='カップル'?'カップル':'友人・ひとり旅',photo:stops.map(slug=>photos[slug]).find(Boolean)||null,image:stops.map(slug=>photos[slug]?.src).find(Boolean)||''}));
export const eventCategories=['祭り・花火','グルメ','マルシェ','自然・アウトドア','文化・展覧会','子ども向け','スポーツ','期間限定体験'];
export const events=[{slug:'sample-riverside',name:'川辺のマルシェ（表示サンプル）',category:'マルシェ',area:'north_niyodo',start_date:'2030-09-01',end_date:'2030-09-01',is_demo:true,description:'日付・名称は画面確認用の架空データです。実際の開催情報ではありません。'}];
export const sortSpots=items=>[...items].sort((a,b)=>b.recommend_count-a.recommend_count||a.initial_rank-b.initial_rank||a.slug.localeCompare(b.slug));
