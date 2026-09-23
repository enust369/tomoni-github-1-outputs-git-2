import {spots,courses,events,areas,sortSpots} from './data.mjs';
import {render,spotGrid,courseGrid,eventCard} from './render.mjs';

const live=!['localhost','127.0.0.1'].includes(location.hostname);
let voted=new Set(),ready=false,anonymousId='';

const toast=message=>{const el=document.querySelector('#toast');if(!el)return;el.textContent=message;el.hidden=false;clearTimeout(toast.timer);toast.timer=setTimeout(()=>el.hidden=true,5000)};
function readLocal(key,fallback){try{return JSON.parse(localStorage.getItem(key))??fallback}catch{return fallback}}
function getIdentity(){let id=localStorage.getItem('kochi-anonymous-id');if(!id){id=crypto.randomUUID();localStorage.setItem('kochi-anonymous-id',id)}return id}
async function api(path,body,method){const r=await fetch(path,{method:method||(body?'POST':'GET'),headers:{'Content-Type':'application/json'},body:body?JSON.stringify(body):undefined});let data;try{data=await r.json()}catch{data=null}if(!r.ok)throw new Error(r.status===429?'操作が続いています。1分ほど待ってください。':'保存できませんでした。通信状態をご確認ください。');return data}

function syncButtons(){document.querySelectorAll('[data-vote]').forEach(b=>{const s=spots.find(s=>s.id===b.dataset.vote);b.disabled=!ready;b.setAttribute('aria-pressed',String(voted.has(b.dataset.vote)));b.innerHTML=`${voted.has(b.dataset.vote)?'♥':'♡'} おすすめ <span>${s?.recommend_count||0}</span>`})}
function filterSpots(){const f=document.querySelector('#spot-filter');if(!f)return;const data=new FormData(f),root=document.querySelector('[data-ranking]');if(!root)return;const cat=root.dataset.ranking;const items=sortSpots(spots.filter(s=>s.category===cat&&(!data.get('area')||s.area===data.get('area'))&&(!data.get('theme')||s.tags?.includes(data.get('theme')))));document.querySelector('#rank-results').innerHTML=spotGrid(items.slice(0,5),true);document.querySelector('#more-results').innerHTML=spotGrid(items.slice(5));syncButtons()}
function preserveQuery(form){const q=new URLSearchParams(location.search);for(const [k,v]of q){const field=form.elements.namedItem(k);if(field)field.value=v}}
function setQuery(form){const q=new URLSearchParams(new FormData(form));[...q].forEach(([k,v])=>{if(!v)q.delete(k)});history.replaceState(null,'',location.pathname+(q.size?'?'+q:''))}
function filterCourses(){const f=document.querySelector('#course-filter');if(!f)return;const d=new FormData(f);const items=courses.filter(c=>['area','theme','duration'].every(k=>!d.get(k)||c[k]===d.get(k)));document.querySelector('#course-results').innerHTML=items.length?courseGrid(items):'<div class="empty">条件に合うコースはありません。条件を変えてお試しください。</div>';document.querySelector('#result-count').textContent=items.length+'件のモデルコース'}
export function matchesPeriod(e,period,now=new Date()){const date=new Intl.DateTimeFormat('sv-SE',{timeZone:'Asia/Tokyo'}).format(now),today=new Date(date+'T00:00:00+09:00'),start=new Date(e.start_date+'T00:00:00+09:00'),end=new Date(e.end_date+'T23:59:59+09:00');if(!period)return true;if(period==='今日'||period==='開催中')return start<=now&&end>=today;if(period==='これから')return start>now;let until;if(period==='今週'){const day=new Date(date+'T00:00:00Z').getUTCDay();until=new Date(today.getTime()+((7-day)%7+1)*86400000-1)}else{const [y,m]=date.split('-').map(Number);until=new Date(Date.UTC(y,m,1)-9*3600000-1)}return start<=until&&end>=today}
function filterEvents(){const form=document.querySelector('#event-filter');if(!form)return;const d=new FormData(form),show=document.querySelector('#show-demo')?.checked;const items=events.filter(e=>(!e.is_demo||show)&&(!d.get('category')||e.category===d.get('category'))&&matchesPeriod(e,d.get('period')));document.querySelector('#event-results').innerHTML=items.length?`<div class="grid">${items.map(eventCard).join('')}</div>`:'<div class="empty">この条件の開催情報はありません。</div>'}

// Presentation-only enhancement: keep the existing select/FormData filter contract.
function enhanceFilters(){
 for(const form of document.querySelectorAll('.filterbar')){
  if(form.classList.contains('enhanced'))continue;
  for(const select of form.querySelectorAll('select')){
   const row=document.createElement('div');row.className='filter-row';
   const title=document.createElement('span');title.className='filter-title';title.textContent=select.parentElement.firstChild.textContent;
   const group=document.createElement('div');group.className='filter-chips';group.setAttribute('role','group');group.setAttribute('aria-label',title.textContent);
   for(const option of select.options){const button=document.createElement('button');button.type='button';button.className='filter-chip';button.textContent=option.textContent;button.dataset.value=option.value;button.setAttribute('aria-pressed',String(select.value===option.value));button.addEventListener('click',()=>{select.value=option.value;form.requestSubmit()});group.append(button)}
   const update=()=>group.querySelectorAll('button').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.value===select.value)));
   form.addEventListener('submit',update);select.addEventListener('change',update);row.append(title,group);form.append(row);
  }
  form.classList.add('enhanced');
 }
}
function initCarousels(){
 for(const carousel of document.querySelectorAll('[data-carousel]')){
  if(carousel.dataset.carouselReady)continue;
  carousel.dataset.carouselReady='true';
  const track=carousel.querySelector('.home-slider-track');
  const slides=[...carousel.querySelectorAll('[data-carousel-slide]')];
  const dots=[...carousel.querySelectorAll('[data-carousel-dot]')];
  if(!track||slides.length<2)continue;
  const reduced=matchMedia('(prefers-reduced-motion: reduce)').matches;
  const index=()=>Math.max(0,Math.min(slides.length-1,Math.round(track.scrollLeft/Math.max(track.clientWidth,1))));
  const active=i=>{slides.forEach((slide,n)=>slide.setAttribute('aria-hidden',String(n!==i)));dots.forEach((dot,n)=>dot.setAttribute('aria-current',String(n===i)));};
  const move=delta=>{const next=(index()+delta+slides.length)%slides.length;track.scrollTo({left:slides[next].offsetLeft,behavior:reduced?'auto':'smooth'});active(next)};
  carousel.querySelector('[data-carousel-prev]')?.addEventListener('click',()=>move(-1));
  carousel.querySelector('[data-carousel-next]')?.addEventListener('click',()=>move(1));
  dots.forEach((dot,n)=>dot.addEventListener('click',()=>{track.scrollTo({left:slides[n].offsetLeft,behavior:reduced?'auto':'smooth'});active(n)}));
  let ticking=false;track.addEventListener('scroll',()=>{if(ticking)return;ticking=true;requestAnimationFrame(()=>{active(index());ticking=false})},{passive:true});
  carousel.addEventListener('keydown',event=>{if(event.key==='ArrowLeft'){event.preventDefault();move(-1)}if(event.key==='ArrowRight'){event.preventDefault();move(1)}});
  active(0);
 }
}
function bind(){
 ['spot','course','event'].forEach(type=>{const f=document.querySelector(`#${type}-filter`);if(!f)return;preserveQuery(f);const fn={spot:filterSpots,course:filterCourses,event:filterEvents}[type];f.addEventListener('submit',e=>{e.preventDefault();setQuery(f);fn()});fn()});
 document.querySelector('#show-demo')?.addEventListener('change',filterEvents);
 const search=document.querySelector('#search-form');
 if(search){preserveQuery(search);const run=()=>{const q=new FormData(search).get('q').trim().toLowerCase();const found=s=>[s.name,areas[s.area],s.theme,...(s.tags||[])].join(' ').toLowerCase().includes(q);document.querySelector('#search-results').innerHTML=q?`<h2>スポット</h2>${spotGrid(spots.filter(found))}<h2>モデルコース</h2>${courseGrid(courses.filter(found))}`:'<p class="muted">探したいスポットやテーマを入力してください。</p>';syncButtons()};search.addEventListener('submit',e=>{e.preventDefault();setQuery(search);run()});run()}
 const form=document.querySelector('#request-form');
 if(form){
   const mode=document.querySelector('#form-mode');
   if(mode)mode.textContent=live?'提案はpending（確認待ち）として保存され、運営確認後に反映されます。':'プレビュー：運営への送信は未接続です。入力内容はこのブラウザに下書きとして保存できます。';
   if(!live)form.querySelector('[type=submit]').textContent='このブラウザに下書きを保存';
   const slug=new URLSearchParams(location.search).get('spot');if(slug&&form.elements.spot_id)form.elements.spot_id.value=spots.find(s=>s.slug===slug)?.id||'';
   form.addEventListener('submit',async e=>{e.preventDefault();const btn=form.querySelector('[type=submit]');btn.disabled=true;const result=document.querySelector('#form-result'),payload=Object.fromEntries(new FormData(form));try{if(live){payload.anonymous_id=anonymousId;await api(form.dataset.kind==='suggest'?'/api/suggest':'/api/correction',payload);result.textContent='提案を受け付けました。運営が確認後に対応します。';form.reset()}else{localStorage.setItem('kochi-draft-'+form.dataset.kind,JSON.stringify(payload));result.textContent='このブラウザに下書きを保存しました。運営には送信されていません。'}}catch(error){result.textContent=error.message}finally{btn.disabled=false}});
   if(!live){const draft=readLocal('kochi-draft-'+form.dataset.kind,{});for(const [key,value]of Object.entries(draft))if(form.elements.namedItem(key))form.elements.namedItem(key).value=value}
 }
 enhanceFilters();
 initCarousels();
 syncButtons();
}

document.addEventListener('click',async e=>{
 const placeholder=e.target.closest('[data-placeholder]');if(placeholder)toast(placeholder.dataset.placeholder);
 const b=e.target.closest('[data-vote]');if(!b||!ready||b.disabled)return;
 const id=b.dataset.vote,s=spots.find(s=>s.id===id);if(!s)return;b.disabled=true;
 try{
   if(live){const result=await api('/api/vote',{spot_id:id,anonymous_id:anonymousId});s.recommend_count=result.recommend_count;result.voted?voted.add(id):voted.delete(id)}
   else{voted.has(id)?voted.delete(id):voted.add(id);localStorage.setItem('kochi-demo-votes',JSON.stringify([...voted]));s.recommend_count=voted.has(id)?1:0;toast('このブラウザの体験用投票です。公開票には加算されません。')}
   filterSpots();const current=document.querySelector('#current-rank');if(current)current.textContent=sortSpots(spots.filter(x=>x.category===s.category)).findIndex(x=>x.id===s.id)+1;syncButtons();
 }catch(error){toast(error.message);b.disabled=false}
});

async function start(){
 anonymousId=getIdentity();
 bind();
 try{
   if(live){
     const state=await api('/api/bootstrap?anonymous_id='+encodeURIComponent(anonymousId),null,'GET');
     const counts=new Map((state.counts||[]).map(x=>[x.spot_id,Number(x.recommend_count||0)]));
     spots.forEach(s=>s.recommend_count=counts.get(s.id)||0);
     voted=new Set(state.voted||[]);
     const doc=new DOMParser().parseFromString(render(location.pathname,'').html,'text/html');
     document.querySelector('main').innerHTML=doc.querySelector('main').innerHTML;
     document.title=doc.title;
     bind();
   }else{
     voted=new Set(readLocal('kochi-demo-votes',[]));spots.forEach(s=>s.recommend_count=voted.has(s.id)?1:0);
     const note=document.createElement('div');note.className='notice wrap';note.textContent='プレビュー：投票・申請はこのブラウザ内の体験用です。';document.querySelector('main').prepend(note);
   }
   ready=true;filterSpots();syncButtons();
 }catch(error){toast(error.message);document.querySelectorAll('[data-vote]').forEach(b=>b.disabled=true)}
}
start();
