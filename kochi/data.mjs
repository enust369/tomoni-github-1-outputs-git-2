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
const rank={};
export const spots=rows.map(([slug,name,category,area,municipality,tags,catchphrase],i)=>({id:`00000000-0000-4000-8000-${String(i+1).padStart(12,'0')}`,slug,name,category,area,municipality,tags:tags.split(','),catchphrase,initial_rank:rank[category]=(rank[category]||0)+1,recommend_count:0,is_published:true,is_demo:true,photo:photos[slug]||null,main_image_url:photos[slug]?.src||'',description:'初期掲載候補です。営業時間・料金などは、公式情報の確認後に掲載します。',created_at:`2026-09-${String(i+1).padStart(2,'0')}T00:00:00Z`}));
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
