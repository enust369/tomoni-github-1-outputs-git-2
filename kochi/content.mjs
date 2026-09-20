import {spots,courses,events} from './data.mjs';
import {setLiveMode} from './render.mjs';
export async function loadContent(url,key){
 async function all(table,query){const result=[];for(let offset=0;;offset+=500){const r=await fetch(`${url}/rest/v1/${table}?${query}&limit=500&offset=${offset}`,{headers:{apikey:key,Authorization:`Bearer ${key}`}});if(!r.ok)throw new Error('公開データを読み込めませんでした。');const batch=await r.json();result.push(...batch);if(batch.length<500)break}return result}
 const [ss,cc,ee]=await Promise.all([all('spots','is_published=eq.true&select=*&order=recommend_count.desc,initial_rank.asc,id.asc'),all('courses','is_published=eq.true&select=*,course_spots(*)&order=initial_rank.asc,id.asc'),all('events','is_published=eq.true&select=*&order=start_date.asc,id.asc')]);
 spots.splice(0,spots.length,...ss);courses.splice(0,courses.length,...cc.map(c=>({...c,image:c.main_image_url,stops:c.course_spots.sort((a,b)=>a.position-b.position).map(x=>spots.find(s=>s.id===x.spot_id)?.slug).filter(Boolean)})));events.splice(0,events.length,...ee);setLiveMode();
}
