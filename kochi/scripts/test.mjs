import {access} from 'node:fs/promises';import {constants} from 'node:fs';import {resolve} from 'node:path';import test from 'node:test';import assert from 'node:assert/strict';import {render,routes} from '../render.mjs';import {isIndexablePath} from '../site.mjs';import {homeSlides} from '../home-content.mjs';import {spots,courses,events,sortSpots} from '../data.mjs';
test('all requested routes render and internal links resolve',()=>{for(const route of routes){const {html,status}=render(route);assert.equal(status,200,route);for(const [,href]of html.matchAll(/href="(\/[^"?#]*)(?:[?#][^"]*)?"/g)){assert.ok(href==='/styles.css'||href==='/favicon.svg'||href.startsWith('/assets/icons/')||routes.includes(href),`${route}: ${href}`)}assert.ok(!html.includes('undefined'),route)}});
test('real vote sorting, then initial rank; no fictitious seed counts',()=>{assert.ok(spots.every(s=>s.recommend_count===0));assert.deepEqual(sortSpots([{slug:'a',initial_rank:1,recommend_count:0},{slug:'b',initial_rank:5,recommend_count:1},{slug:'c',initial_rank:2,recommend_count:0}]).map(s=>s.slug),['b','a','c']);assert.deepEqual(sortSpots(spots.filter(s=>s.category==='sightseeing')).slice(0,3).map(s=>s.slug),['ryugado','nikobuchi','iokido']);assert.equal(courses.length,10)});
test('unknown routes return 404 and SEO metadata is per-page',()=>{assert.equal(render('/no-such-route/').status,404);const html=render('/spots/nikobuchi/','https://kochi.example').html;assert.match(html,/<title>にこ淵/);assert.match(html,/rel="canonical" href="https:\/\/kochi.example\/spots\/nikobuchi\/"/);assert.match(html,/noindex,nofollow/);assert.match(render('/','https://kochi.example',true).html,/index,follow/)});
test('home slider uses seven configured slides and accessible controls',()=>{const html=render('/').html;assert.equal(homeSlides.length,7);assert.equal((html.match(/data-carousel-slide/g)||[]).length,homeSlides.length);assert.match(html,/kochi-sup-hero\.png/);for(const src of ['hero-paragliding.png','hero-buggy.png','hero-forest-adventure.png','hero-camping.png','hero-rafting.png','hero-ryugado.png'])assert.match(html,new RegExp(src));assert.equal((html.match(/data-carousel-dot/g)||[]).length,homeSlides.length);assert.equal((html.match(/data-carousel-index/g)||[]).length,homeSlides.length);assert.match(html,/data-carousel-prev/);assert.match(html,/data-carousel-next/);assert.match(html,/class="home-search"/);assert.match(html,/aria-label="エリア"/);for(const slide of homeSlides){assert.match(html,new RegExp(slide.href.replace(/[.*+?^${}()|[\]\\]/g,'\\$&')))}});
test('sitemap route selection excludes private, sample, and empty category pages',()=>{assert.equal(isIndexablePath('/spots/nikobuchi/'),true);assert.equal(isIndexablePath('/gourmet/'),true);assert.equal(isIndexablePath('/fishing/'),true);assert.equal(isIndexablePath('/surfing/'),true);assert.equal(isIndexablePath('/suggest/'),true);assert.equal(isIndexablePath('/search/'),false);assert.equal(isIndexablePath('/stay/'),false);assert.equal(isIndexablePath('/events/sample-riverside/'),false)});
test('events page server-renders verified event cards',()=>{const html=render('/events/').html;assert.equal((html.match(/class=\"card event-card\"/g)||[]).length,events.filter(e=>!e.is_demo).length);assert.doesNotMatch(html,/確認済みの開催情報はまだありません/)});
test('fishing and surfing rankings have published spots',()=>{const fishing=spots.filter(s=>s.category==='fishing'&&s.is_published!==false);const surfing=spots.filter(s=>s.category==='surfing'&&s.is_published!==false);assert.equal(fishing.length,4);assert.equal(surfing.length,3);assert.match(render('/fishing/').html,/須崎・富士ヶ浜 海釣り体験/);assert.match(render('/surfing/').html,/生見サーフィンビーチ/)});
test('published spots do not expose demo or verification placeholder copy',()=>{assert.ok(spots.every(s=>s.is_demo===false));assert.ok(spots.every(s=>!String(s.description||'').includes('初期掲載候補')));const html=render('/spots/kashiwajima/').html;assert.doesNotMatch(html,/未確認|確認中|初期掲載候補/)});
test('legal, privacy, and contact pages use the approved public details',()=>{const terms=render('/terms/').html,privacy=render('/privacy/').html,contact=render('/contact/').html;assert.match(terms,/<h1>利用規約<\/h1>/);assert.doesNotMatch(terms,/公開前草案/);assert.match(privacy,/localStorage/);assert.doesNotMatch(privacy,/公開前草案/);assert.match(contact,/mailto:luidabase@gmail\.com/);assert.match(contact,/掲載追加申請/);assert.match(contact,/情報修正申請/)});

const meta=(html,key)=>html.match(new RegExp(`<meta (?:name|property)="${key}" content="([^"]*)"`))?.[1];
const structured=html=>[...html.matchAll(/<script type="application\/ld\+json">(.*?)<\/script>/gs)].map(match=>JSON.parse(match[1]));
const seoOrigin='https://seo.kochi.example';
test('every page has absolute OGP and matching Twitter metadata; details use their own photos',()=>{
  const unavailable=new Set(['/assets/photos/ashizuri.jpg','/assets/photos/chikurinji.png','/assets/photos/course-karst-panorama.png','/assets/photos/course-niyodo-sauna.png','/assets/photos/event-okawa.png','/assets/photos/event-okyaku.png','/assets/photos/karst.jpg','/assets/photos/kashiwajima.jpg','/assets/photos/kochi-castle.jpg','/assets/photos/ryugado.jpg','/assets/photos/yasui.jpg','/assets/photos/yusuhara.jpg']);
  const safeImage=path=>unavailable.has(path)?homeSlides[0].photo.src:path;
  const expected=new Map([['/',homeSlides[0].photo.src],...spots.map(s=>[`/spots/${s.slug}/`,safeImage(s.photo?.src)]),...courses.map(c=>[`/courses/${c.slug}/`,safeImage(c.photo?.src)]),...events.map(e=>[`/events/${e.slug}/`,safeImage(e.image)])]);
  for(const path of routes){
    const html=render(path,seoOrigin).html;
    assert.equal(meta(html,'og:image'),new URL(expected.get(path)||homeSlides[0].photo.src,seoOrigin).href,path);
    assert.equal(meta(html,'twitter:image'),meta(html,'og:image'));
    assert.equal(meta(html,'twitter:card'),'summary_large_image');
    assert.equal(meta(html,'twitter:title'),html.match(/<title>(.*?)<\/title>/s)[1]);
    assert.equal(meta(html,'twitter:description'),meta(html,'description'));
  }
});
test('generated OGP image files exist in the deployable asset directory',async()=>{
  for(const path of routes){
    const image=new URL(meta(render(path,seoOrigin).html,'og:image'));
    if(image.origin===seoOrigin)await access(resolve(import.meta.dirname,'..','dist','.'+image.pathname),constants.R_OK);
    else assert.equal(image.protocol,'https:');
  }
});
test('home has one H1 and six H2 slide titles without changing slide copy',()=>{
  const html=render('/').html;
  assert.equal([...html.matchAll(/<h1(?:\s[^>]*)?>/g)].length,1);
  assert.equal([...html.matchAll(/<h2 class="home-slide-title">/g)].length,6);
  assert.ok(html.includes(`<h1 class="home-slide-title">${homeSlides[0].title}</h1>`));
});
test('major listing pages have distinct relevant titles and descriptions',()=>{
  const titles=new Set(),descriptions=new Set();
  for(const [route,keyword] of Object.entries({sightseeing:'観光',gourmet:'グルメ',activity:'アクティビティ',fishing:'釣り',surfing:'サーフィン',courses:'モデルコース',events:'イベント',area:'エリア',features:'特集',guide:'お役立ち情報'})){
    const html=render(`/${route}/`).html,title=html.match(/<title>(.*?)<\/title>/s)[1],description=meta(html,'description');
    assert.ok(title.includes('高知')&&title.includes(keyword),route);
    assert.ok(description.includes('高知'),route);
    assert.ok(!titles.has(title)&&!descriptions.has(description),route);
    titles.add(title);descriptions.add(description);
  }
  for(const key of ['og:title','description'])assert.ok(meta(render('/activity/').html,key).includes('体験'));
});
test('Organization and breadcrumbs are valid JSON-LD with consistent names and URLs',()=>{
  const [org,website]=structured(render('/',seoOrigin).html);
  assert.equal(website['@type'],'WebSite');assert.equal(website.name,'高知観光ランキング');assert.equal(website.url,seoOrigin);
  assert.equal(org['@type'],'Organization');assert.equal(org.name,'高知観光ランキング運営事務局');assert.equal(org.url,seoOrigin);assert.equal(org.email,'luidabase@gmail.com');
  for(const path of routes){
    const html=render(path,seoOrigin,true).html,data=structured(html);
    assert.ok(data.every(item=>item['@type']!=='Event'));
    if(path==='/'||!isIndexablePath(path))continue;
    assert.equal(data[0]['@context'],'https://schema.org');assert.equal(data[0]['@type'],'BreadcrumbList');
    const crumbs=data[0].itemListElement;
    assert.equal(crumbs[0].name,'高知観光ランキング');assert.equal(crumbs.at(-1).item,new URL(path,seoOrigin).href);
    for(const [i,crumb] of crumbs.entries()){assert.equal(crumb.position,i+1);assert.ok(routes.includes(new URL(crumb.item).pathname));assert.ok(html.includes(crumb.name),`${path}: ${crumb.name}`);}
  }
  assert.equal(structured(render('/missing/',seoOrigin).html).length,0);
});
test('canonical, verification and robots remain correct for every route in both indexing modes',()=>{
  for(const path of routes)for(const enabled of [false,true]){
    const html=render(path,seoOrigin,enabled).html;
    assert.ok(html.includes(`<link rel="canonical" href="${new URL(path,seoOrigin).href}">`),path);
    assert.equal(meta(html,'og:url'),new URL(path,seoOrigin).href);
    assert.equal(meta(html,'robots'),enabled&&isIndexablePath(path)?'index,follow':'noindex,nofollow',path);
    assert.equal(meta(html,'google-site-verification'),'j0jdY1lGkbx4WJENSEIsxvwWHxyX5CEY5NcRc6riXx4');
  }
  for(const path of ['/search/','/mypage/','/login/','/missing/'])assert.equal(meta(render(path,seoOrigin,true).html,'robots'),'noindex,nofollow');
  assert.doesNotMatch(render('/missing/',seoOrigin,true).html,/rel="canonical"/);
});
