import {spots,courses,events,areas,categories} from '../data.mjs';

const photo=p=>p?{
  src:p.src||'',alt:p.alt||'',width:p.width||0,height:p.height||0,position:p.position||'',
  name:p.name||'',author:p.author||'',source:p.source||'',license:p.license||'',licenseUrl:p.licenseUrl||''
}:null;
const clientSpots=spots.map(s=>({
  id:s.id,slug:s.slug,name:s.name,category:s.category,area:s.area,municipality:s.municipality,initial_rank:s.initial_rank,
  tags:s.tags||[],catchphrase:s.catchphrase||'',description:s.description||'',recommend_count:Number(s.recommend_count)||0,
  photo:photo(s.photo)
}));
const clientCourses=courses.map(c=>({
  slug:c.slug,name:c.name,area:c.area,theme:c.theme,duration:c.duration,transport:c.transport,
  stops:c.stops||[],photo:photo(c.photo)
}));
const clientEvents=events.map(e=>({
  slug:e.slug,name:e.name,category:e.category,area:e.area,start_date:e.start_date,end_date:e.end_date,
  venue:e.venue||'',image:e.image||'',image_alt:e.image_alt||'',image_note:e.image_note||'',is_demo:Boolean(e.is_demo)
}));
export const clientDataSource=`export const areas=${JSON.stringify(areas)};\nexport const categories=${JSON.stringify(categories)};\nexport const spots=${JSON.stringify(clientSpots)};\nexport const courses=${JSON.stringify(clientCourses)};\nexport const events=${JSON.stringify(clientEvents)};\nexport const sortSpots=items=>[...items].sort((a,b)=>(Number(b.recommend_count)||0)-(Number(a.recommend_count)||0)||(Number(a.initial_rank)||999)-(Number(b.initial_rank)||999)||String(a.name).localeCompare(String(b.name),'ja'));\n`;
