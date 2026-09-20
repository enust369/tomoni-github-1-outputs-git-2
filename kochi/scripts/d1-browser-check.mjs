// Requires wrangler dev --local on KOCHI_D1_TEST_ORIGIN with fixtures/d1-test.sql.
// Only local D1 is exercised. Never point this at production.
import {chromium} from '/Users/ogasawara/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright/index.mjs';
import assert from 'node:assert/strict';
const upstream=process.env.KOCHI_D1_TEST_ORIGIN||'http://127.0.0.1:4176';
assert.ok(['localhost','127.0.0.1'].includes(new URL(upstream).hostname));
const browser=await chromium.launch({headless:true,channel:'chrome'});
try{
 const page=await browser.newPage({viewport:{width:390,height:844}}),errors=[],responses=[];
 page.on('pageerror',error=>errors.push(error.message));
 // A test hostname activates the unchanged production branch in app.mjs.
 // Every request for it is forwarded to the LOCAL Worker, not mocked.
 await page.route('https://kochi.test/**',async route=>{
  const request=route.request(),url=new URL(request.url());
  const response=await route.fetch({url:upstream+url.pathname+url.search});
  if(url.pathname.startsWith('/api/'))responses.push({path:url.pathname,method:request.method(),status:response.status(),body:await response.json(),payload:request.postDataJSON()});
  await route.fulfill({response});
 });
 await page.goto('https://kochi.test/sightseeing/');
 const vote=page.locator('#rank-results .vote').first();
 await page.waitForFunction(()=>document.querySelector('#rank-results .vote')?.disabled===false);
 assert.equal(await vote.locator('span').innerText(),'0');
 await vote.click();await page.waitForFunction(()=>document.querySelector('#rank-results .vote')?.getAttribute('aria-pressed')==='true');
 assert.equal(await vote.locator('span').innerText(),'1');
 await page.reload();await page.waitForFunction(()=>document.querySelector('#rank-results .vote')?.disabled===false);
 assert.equal(await vote.getAttribute('aria-pressed'),'true');assert.equal(await vote.locator('span').innerText(),'1');
 await vote.click();await page.waitForFunction(()=>document.querySelector('#rank-results .vote')?.getAttribute('aria-pressed')==='false');
 assert.equal(await vote.locator('span').innerText(),'0');
 await page.locator('#spot-filter .filter-chip[data-value=east]').click();
 assert.equal(await page.locator('#rank-results .card').count(),4);
 for(const kind of ['suggest','correction']){
  await page.goto('https://kochi.test/'+kind+'/');
  await page.waitForFunction(()=>document.querySelector('#form-mode')?.textContent.includes('pending'));
  if(kind==='suggest'){
   await page.locator('[name=name]').fill('LOCAL D1 integration test');
   await page.locator('[name=category]').selectOption('sightseeing');await page.locator('[name=area]').selectOption('east');await page.locator('[name=municipality]').fill('ローカル試験');
  }else{
   await page.locator('[name=spot_id]').selectOption({index:1});await page.locator('[name=target]').selectOption('営業時間');
  }
  await page.locator('[name=reason]').fill('ローカル結合テスト。本番には送信しない。');
  await page.locator('#request-form button[type=submit]').click();
  await page.waitForFunction(()=>document.querySelector('#form-result')?.textContent.includes('受け付けました'));
 }
 const votes=responses.filter(r=>r.path==='/api/vote');
 assert.deepEqual(votes.map(r=>[r.body.recommend_count,r.body.voted]),[[1,true],[0,false]]);
 for(const path of ['/api/suggest','/api/correction']){
  const response=responses.find(r=>r.path===path);assert.equal(response.status,201);assert.equal(response.body.status,'pending');assert.ok(response.payload.anonymous_id);assert.equal(response.payload.status,undefined);
 }
 for(const width of [390,1440]){
  await page.setViewportSize({width,height:900});
  for(const path of ['/','/sightseeing/','/courses/','/courses/niyodo-classic/']){
   await page.goto('https://kochi.test'+path);await page.waitForFunction(()=>!document.querySelector('[data-vote]:disabled'));
   assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false,`${width}: ${path}`);
   await page.screenshot({path:`/private/tmp/kochi-d1-${width}-${path.split('/').filter(Boolean).join('-')||'home'}.png`});
  }
 }
 assert.deepEqual(errors,[]);
 console.log('PASS unchanged Worker + local D1: bootstrap, vote 0→1→0, reload, filters, suggest/correction pending, mobile and desktop');
 console.log(JSON.stringify(responses.filter(r=>['/api/vote','/api/suggest','/api/correction'].includes(r.path)).map(({path,status,body})=>({path,status,body})),null,2));
}finally{await browser.close()}
