let spots=[],courses=[],events=[],areas={},categories={},sortSpots=items=>[...items];
let clientDataLoaded=false;
async function loadClientData(){if(clientDataLoaded)return;({spots,courses,events,areas,categories,sortSpots}=await import('./client-data.mjs'));clientDataLoaded=true}

const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const photoImage=(photo,name)=>`<img src="${esc(photo?.src||'/assets/photos/unset.svg')}" alt="${esc(photo?.alt||name+'：写真未設定')}" width="${photo?.width||1280}" height="${photo?.height||800}" style="object-position:${esc(photo?.position||'50% 50%')}" loading="lazy" fetchpriority="low" decoding="async">`;
const photoCredit=photo=>{if(!photo?.author&&!photo?.license)return '';const subject=photo.source?`<a href="${esc(photo.source)}" target="_blank" rel="noopener">${esc(photo.name)} / ${esc(photo.author)}</a>`:`${esc(photo.name)} / ${esc(photo.author)}`;const license=photo.licenseUrl?`<a href="${esc(photo.licenseUrl)}" target="_blank" rel="noopener">${esc(photo.license)}</a>`:esc(photo.license||'');return `<p class="photo-credit">写真：${subject}${license?' · '+license:''}</p>`};
const spotCard=(s,i)=>`<article class="card spot-card ${i!==undefined?'rank-card':''}"><a href="/spots/${esc(s.slug)}/">${photoImage(s.photo,s.name)}${i!==undefined?`<span class="badge ${['gold','silver','bronze','other','other'][i]||'other'}">${i+1}</span>`:''}<div class="card-body"><span class="label">${esc(areas[s.area])} · ${esc(categories[s.category])}</span><h3>${esc(s.name)}</h3><p>${esc(s.catchphrase)}</p></div></a>${photoCredit(s.photo)}<div class="card-body vote-container"><button class="vote" data-vote="${esc(s.id)}" aria-pressed="false">♡ おすすめ <span>${Number(s.recommend_count)||0}</span></button></div></article>`;
const spotGrid=(items,rank=false)=>items.length?`<div class="grid spots-grid ${rank?'rank-grid':''}">${items.map((s,i)=>spotCard(s,rank?i:undefined)).join('')}</div>`:'<div class="empty"><h3>条件に合うスポットはありません。</h3><p>条件を変えて探すか、あなたのおすすめスポットを教えてください。</p><a class="button" href="/search/">条件を変えて探す</a> <a class="button" href="/suggest/">スポットを提案する</a></div>';
const courseCard=c=>`<article class="card course-card"><a href="/courses/${esc(c.slug)}/">${photoImage(c.photo,c.name)}<div class="card-body"><span class="label">${esc(areas[c.area])} · ${esc(c.duration)}</span><h3>${esc(c.name)}</h3><p>${esc(c.theme)} / ${esc(c.transport)}</p></div></a>${photoCredit(c.photo)}</article>`;
const courseGrid=items=>`<div class="grid course-grid">${items.filter(Boolean).map(courseCard).join('')}</div>`;
const eventCard=e=>`<article class="card event-card">${e.image?`<a class="event-image-wrap" href="/events/${esc(e.slug)}/"><img class="event-image" src="${esc(e.image)}" alt="${esc(e.image_alt||e.name)}" loading="lazy" fetchpriority="low" decoding="async">${e.image_note?`<span class="event-image-note">${esc(e.image_note)}</span>`:''}</a>`:''}<div class="card-body"><span class="label">${esc(e.category)} · ${esc(areas[e.area])}</span><h3><a href="/events/${esc(e.slug)}/">${esc(e.name)}</a></h3><p class="event-date">${esc(e.start_date)}${e.end_date!==e.start_date?' ～ '+esc(e.end_date):''}</p>${e.venue?`<p class="muted event-venue">${esc(e.venue)}</p>`:''}</div></article>`;
const featuredCategoryTop3=items=>{const top=items.slice(0,3);if(!top.length)return '<div class="empty"><h3>条件に合うスポットはありません。</h3><p>条件を変えて探してみてください。</p></div>';return `<div class="category-top3 count-${top.length}"><article class="category-top3-card category-top3-first"><a href="/spots/${esc(top[0].slug)}/">${photoImage(top[0].photo,top[0].name)}<span class="category-top3-rank rank-1">1</span><div class="category-top3-body"><span>${esc(areas[top[0].area])}</span><h3>${esc(top[0].name)}</h3><p>${esc(top[0].catchphrase)}</p></div></a>${photoCredit(top[0].photo)}<button class="vote" data-vote="${esc(top[0].id)}" aria-pressed="false">♡ おすすめ <span>${Number(top[0].recommend_count)||0}</span></button></article>${top.length>1?`<div class="category-top3-side">${top.slice(1).map((spot,i)=>`<article class="category-top3-card category-top3-small"><a href="/spots/${esc(spot.slug)}/">${photoImage(spot.photo,spot.name)}<span class="category-top3-rank rank-${i+2}">${i+2}</span><div class="category-top3-body"><span>${esc(areas[spot.area])}</span><h3>${esc(spot.name)}</h3><p>${esc(spot.catchphrase)}</p></div></a>${photoCredit(spot.photo)}<button class="vote" data-vote="${esc(spot.id)}" aria-pressed="false">♡ おすすめ <span>${Number(spot.recommend_count)||0}</span></button></article>`).join('')}</div>`:''}</div>`};

const live=!['localhost','127.0.0.1'].includes(location.hostname);
let voted=new Set(),voteCounts=new Map(),ready=false,anonymousId='',savedSpots=new Set(),savedCourses=new Set();

const toast=message=>{const el=document.querySelector('#toast');if(!el)return;el.textContent=message;el.hidden=false;clearTimeout(toast.timer);toast.timer=setTimeout(()=>el.hidden=true,5000)};
function readLocal(key,fallback){try{return JSON.parse(localStorage.getItem(key))??fallback}catch{return fallback}}
function getIdentity(){let id=localStorage.getItem('kochi-anonymous-id');if(!id){id=crypto.randomUUID();localStorage.setItem('kochi-anonymous-id',id)}return id}
async function api(path,body,method){const r=await fetch(path,{method:method||(body?'POST':'GET'),headers:{'Content-Type':'application/json'},body:body?JSON.stringify(body):undefined});let data;try{data=await r.json()}catch{data=null}if(!r.ok)throw new Error(r.status===429?'操作が続いています。1分ほど待ってください。':'保存できませんでした。通信状態をご確認ください。');return data}

function syncButtons(){document.querySelectorAll('[data-vote]').forEach(b=>{const id=b.dataset.vote,s=spots.find(s=>s.id===id);const count=voteCounts.has(id)?voteCounts.get(id):(s?.recommend_count||0);b.disabled=!ready;b.setAttribute('aria-pressed',String(voted.has(id)));b.innerHTML=`${voted.has(id)?'♥':'♡'} おすすめ <span>${count}</span>`});document.querySelectorAll('[data-save-spot]').forEach(b=>{const saved=savedSpots.has(b.dataset.saveSpot);b.setAttribute('aria-pressed',String(saved));b.textContent=saved?'♥ 保存済み':'♡ 行ってみたい'});document.querySelectorAll('[data-save-course]').forEach(b=>{const saved=savedCourses.has(b.dataset.saveCourse);b.setAttribute('aria-pressed',String(saved));b.textContent=saved?'♥ 保存済み':'♡ コースを保存'})}
function renderSavedTrips(){const spotRoot=document.querySelector('#saved-spots'),courseRoot=document.querySelector('#saved-courses');if(spotRoot){const items=spots.filter(s=>savedSpots.has(s.slug));spotRoot.innerHTML=items.length?spotGrid(items):'<div class="empty">まだ保存したスポットはありません。スポット詳細の「行ってみたい」から追加できます。</div>'}if(courseRoot){const items=courses.filter(c=>savedCourses.has(c.slug));courseRoot.innerHTML=items.length?courseGrid(items):'<div class="empty">まだ保存したモデルコースはありません。コース詳細の「コースを保存」から追加できます。</div>'}syncButtons()}
function saveLocalTrips(){localStorage.setItem('kochi-saved-spots',JSON.stringify([...savedSpots]));localStorage.setItem('kochi-saved-courses',JSON.stringify([...savedCourses]))}
function filterSpots(){const f=document.querySelector('#spot-filter');if(!f)return;const data=new FormData(f),root=document.querySelector('[data-ranking]');if(!root)return;const cat=root.dataset.ranking;const historyOnly=root.dataset.historyOnly==='true';const historySlugs=new Set(['kochi-castle','chikurinji','kochi-castle-history-museum','sakamoto-ryoma-memorial-museum','makino-botanical-garden','shioe-tenmangu']);const items=sortSpots(spots.filter(s=>s.category===cat&&(!historyOnly||historySlugs.has(s.slug))&&(!data.get('area')||s.area===data.get('area'))&&(!data.get('theme')||s.tags?.includes(data.get('theme')))));const specialTop3=['camp','onsen','michinoeki'].includes(cat);document.querySelector('#rank-results').innerHTML=specialTop3?featuredCategoryTop3(items):spotGrid(items.slice(0,5),true);document.querySelector('#more-results').innerHTML=spotGrid(items.slice(specialTop3?3:5));syncButtons()}
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
  const numbers=[...carousel.querySelectorAll('[data-carousel-index]')];
  const active=i=>{slides.forEach((slide,n)=>slide.setAttribute('aria-hidden',String(n!==i)));dots.forEach((dot,n)=>dot.setAttribute('aria-current',String(n===i)));numbers.forEach((number,n)=>number.setAttribute('aria-current',String(n===i)));};
  const ensureSlide=async i=>{const img=slides[i]?.querySelector('img');if(!img||img.complete&&img.naturalWidth>0)return;img.loading='eager';img.fetchPriority='high';await Promise.race([img.decode?.().catch(()=>{}),new Promise(resolve=>{img.addEventListener('load',resolve,{once:true});img.addEventListener('error',resolve,{once:true})}),new Promise(resolve=>setTimeout(resolve,3000))])};
  const warmNext=i=>{const next=(i+1)%slides.length;ensureSlide(next).then(()=>{const img=slides[next]?.querySelector('img');if(img)img.fetchPriority='low'})};
  const go=async next=>{await ensureSlide(next);track.scrollTo({left:slides[next].offsetLeft,behavior:reduced?'auto':'smooth'});active(next);warmNext(next)};
  const move=delta=>go((index()+delta+slides.length)%slides.length);
  let timer=0,resumeTimer=0;
  const stop=()=>{clearInterval(timer);timer=0;clearTimeout(resumeTimer);};
  const start=()=>{if(!reduced&&!timer)timer=setInterval(()=>move(1),6500);};
  const resume=()=>{stop();resumeTimer=setTimeout(start,8500)};
  carousel.querySelector('[data-carousel-prev]')?.addEventListener('click',()=>{move(-1);resume()});
  carousel.querySelector('[data-carousel-next]')?.addEventListener('click',()=>{move(1);resume()});
  dots.forEach((dot,n)=>dot.addEventListener('click',()=>{go(n);resume()}));
  let ticking=false;track.addEventListener('scroll',()=>{if(ticking)return;ticking=true;requestAnimationFrame(()=>{active(index());ticking=false})},{passive:true});
  carousel.addEventListener('keydown',event=>{if(event.key==='ArrowLeft'){event.preventDefault();move(-1);resume()}if(event.key==='ArrowRight'){event.preventDefault();move(1);resume()}});
  track.addEventListener('pointerdown',resume,{passive:true});
  carousel.addEventListener('mouseenter',stop);carousel.addEventListener('mouseleave',start);carousel.addEventListener('focusin',stop);carousel.addEventListener('focusout',start);
  active(0);
  warmNext(0);
  start();
 }
}
function bind(){
 savedSpots=new Set(readLocal('kochi-saved-spots',[]));savedCourses=new Set(readLocal('kochi-saved-courses',[]));renderSavedTrips();
 const homeKeywordForm=document.querySelector('[data-home-keyword-form]');if(homeKeywordForm)homeKeywordForm.addEventListener('submit',e=>{e.preventDefault();homeKeywordForm.querySelector('[data-search-open]')?.click()});
 ['spot','course','event'].forEach(type=>{const f=document.querySelector(`#${type}-filter`);if(!f)return;preserveQuery(f);const fn={spot:filterSpots,course:filterCourses,event:filterEvents}[type];f.addEventListener('submit',e=>{e.preventDefault();setQuery(f);fn()});fn()});
 document.querySelector('#show-demo')?.addEventListener('change',filterEvents);
 const search=document.querySelector('#search-form');
 if(search){preserveQuery(search);const run=()=>{const data=new FormData(search),q=String(data.get('q')||'').trim().toLowerCase(),area=String(data.get('area')||''),category=String(data.get('category')||''),theme=String(data.get('theme')||'');const keywordAliases={'歴史文化':['歴史'],'仁淀ブルー':['仁淀川'],'ナイトライフ':['居酒屋','ディナー','屋台']};const textMatch=(values)=>{if(!q)return true;const text=values.filter(Boolean).join(' ').toLowerCase();const terms=[q,...(keywordAliases[q]||[])].map(x=>String(x).toLowerCase());return terms.some(term=>text.includes(term))};const themeAliases={王道:['王道','定番'],グルメ:['グルメ','郷土料理','カツオ','ランチ','ディナー','居酒屋','ラーメン','スイーツ'],子連れ:['子連れ'],カップル:['カップル','デート'],絶景:['絶景'],ドライブ:['ドライブ'],アクティブ:['アクティブ','アクティビティ','川あそび','洞窟体験'],雨の日:['雨の日']};const spotThemeMatch=s=>!theme||(themeAliases[theme]||[theme]).some(t=>[s.name,categories[s.category],s.catchphrase,s.description,...(s.tags||[])].filter(Boolean).join(' ').includes(t));const foundSpots=spots.filter(s=>textMatch([s.name,areas[s.area],categories[s.category],s.municipality,s.catchphrase,s.description,...(s.tags||[])])&&(!area||s.area===area)&&(!category||s.category===category)&&spotThemeMatch(s));const foundCourses=courses.filter(c=>{const stopSpots=(c.stops||[]).map(slug=>spots.find(s=>s.slug===slug)).filter(Boolean);return textMatch([c.name,areas[c.area],c.theme,c.duration,...stopSpots.map(s=>s.name),...stopSpots.flatMap(s=>s.tags||[])])&&(!area||c.area===area)&&(!category||stopSpots.some(s=>s.category===category))&&(!theme||c.theme===theme)});const hasFilter=Boolean(q||area||category||theme);const summary=document.querySelector('#search-summary'),results=document.querySelector('#search-results');if(!hasFilter){const picks=spots.filter(s=>['ryugado','nikobuchi','kochi-castle','kashiwajima','iokido','shirasu'].includes(s.slug));summary.textContent='まずは人気スポットから。キーワードや条件を入れるとさらに絞り込めます。';results.innerHTML=`<section class="search-result-section"><div class="section-head"><div><div class="eyebrow">RECOMMENDED</div><h2>おすすめスポット</h2></div></div>${spotGrid(picks)}</section>`;syncButtons();return}summary.textContent=`スポット ${foundSpots.length}件・モデルコース ${foundCourses.length}件`;results.innerHTML=`<section class="search-result-section"><div class="section-head"><div><div class="eyebrow">SPOTS</div><h2>スポット ${foundSpots.length}件</h2></div></div>${foundSpots.length?spotGrid(foundSpots):'<div class="empty">条件に合うスポットはありません。キーワードや条件を変えてお試しください。</div>'}</section><section class="search-result-section"><div class="section-head"><div><div class="eyebrow">MODEL COURSES</div><h2>モデルコース ${foundCourses.length}件</h2></div></div>${foundCourses.length?courseGrid(foundCourses):'<div class="empty">条件に合うモデルコースはありません。</div>'}</section>`;syncButtons()};search.addEventListener('submit',e=>{e.preventDefault();setQuery(search);run()});search.addEventListener('change',()=>{setQuery(search);run()});run()}
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
 const openSearch=e.target.closest('[data-search-open]');
 if(openSearch){
   e.preventDefault();
   const modal=document.querySelector('#home-search-modal');
   if(modal){const source=openSearch.closest('[data-home-keyword-form]')?.querySelector('input[name="q"]');const target=modal.querySelector('#home-search-input');if(source&&target)target.value=source.value.trim();modal.hidden=false;document.body.classList.add('search-modal-open');target?.focus()}
   return;
 }
 const closeSearch=e.target.closest('[data-search-close]');
 const modal=e.target.closest('#home-search-modal');
 if(closeSearch||(modal&&e.target===modal)){
   if(modal){modal.hidden=true;document.body.classList.remove('search-modal-open')}
   return;
 }
 const saveSpot=e.target.closest('[data-save-spot]');if(saveSpot){const slug=saveSpot.dataset.saveSpot;savedSpots.has(slug)?savedSpots.delete(slug):savedSpots.add(slug);saveLocalTrips();syncButtons();renderSavedTrips();toast(savedSpots.has(slug)?'行ってみたいスポットに保存しました。':'保存を解除しました。');return}
 const saveCourse=e.target.closest('[data-save-course]');if(saveCourse){const slug=saveCourse.dataset.saveCourse;savedCourses.has(slug)?savedCourses.delete(slug):savedCourses.add(slug);saveLocalTrips();syncButtons();renderSavedTrips();toast(savedCourses.has(slug)?'モデルコースを保存しました。':'保存を解除しました。');return}
 const placeholder=e.target.closest('[data-placeholder]');if(placeholder)toast(placeholder.dataset.placeholder);
 const b=e.target.closest('[data-vote]');if(!b||!ready||b.disabled)return;
 const id=b.dataset.vote,s=spots.find(s=>s.id===id);b.disabled=true;
 try{
   if(live){const result=await api('/api/vote',{spot_id:id,anonymous_id:anonymousId});voteCounts.set(id,Number(result.recommend_count)||0);if(s)s.recommend_count=Number(result.recommend_count)||0;result.voted?voted.add(id):voted.delete(id)}
   else{voted.has(id)?voted.delete(id):voted.add(id);localStorage.setItem('kochi-demo-votes',JSON.stringify([...voted]));voteCounts.set(id,voted.has(id)?1:0);if(s)s.recommend_count=voted.has(id)?1:0;toast('このブラウザの体験用投票です。公開票には加算されません。')}
   filterSpots();const current=document.querySelector('#current-rank');if(current&&s)current.textContent=sortSpots(spots.filter(x=>x.category===s.category)).findIndex(x=>x.id===s.id)+1;syncButtons();
 }catch(error){toast(error.message);b.disabled=false}
});

document.addEventListener('keydown',e=>{
 if(e.key!=='Escape')return;
 const modal=document.querySelector('#home-search-modal');
 if(modal&&!modal.hidden){modal.hidden=true;document.body.classList.remove('search-modal-open');document.querySelector('[data-search-open]')?.focus()}
});

async function start(){
 const hasVotes=Boolean(document.querySelector('[data-vote]'));
 const needsData=Boolean(document.querySelector('#current-rank,#spot-filter,#course-filter,#event-filter,#search-form,#saved-spots,#saved-courses,#request-form'));
 const needsVoteState=hasVotes||Boolean(document.querySelector('#spot-filter,#search-form,#saved-spots'));
 try{
   if(needsData)await loadClientData();
   if(needsVoteState||document.querySelector('#request-form'))anonymousId=getIdentity();
   bind();
   if(!live){
     if(needsVoteState){voted=new Set(readLocal('kochi-demo-votes',[]));for(const id of document.querySelectorAll('[data-vote]'))voteCounts.set(id.dataset.vote,voted.has(id.dataset.vote)?1:0);if(clientDataLoaded)spots.forEach(s=>s.recommend_count=voted.has(s.id)?1:0)}
     const note=document.createElement('div');note.className='notice wrap';note.textContent='プレビュー：投票・申請はこのブラウザ内の体験用です。';document.querySelector('main').prepend(note);
   }else if(needsVoteState){
     const state=await api('/api/bootstrap?anonymous_id='+encodeURIComponent(anonymousId),null,'GET');
     voteCounts=new Map((state.counts||[]).map(x=>[x.spot_id,Number(x.recommend_count||0)]));
     if(clientDataLoaded)spots.forEach(s=>s.recommend_count=voteCounts.get(s.id)||0);
     voted=new Set(state.voted||[]);
   }
   ready=true;filterSpots();syncButtons();
 }catch(error){toast(error.message);document.querySelectorAll('[data-vote]').forEach(b=>b.disabled=true)}
}
start();
