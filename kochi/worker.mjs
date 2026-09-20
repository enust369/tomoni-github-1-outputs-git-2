const json=(data,status=200)=>new Response(JSON.stringify(data),{status,headers:{'content-type':'application/json; charset=utf-8','cache-control':'no-store'}});
const bad=(message,status=400)=>json({error:message},status);
const isId=v=>typeof v==='string'&&/^[0-9a-f-]{36}$/i.test(v);
async function body(request){try{return await request.json()}catch{return null}}
async function budget(db,identity,operation,max){
  const now=Math.floor(Date.now()/60000);
  await db.prepare(`INSERT INTO request_budgets(identity,operation,window_start,attempts)
    VALUES(?,?,?,1)
    ON CONFLICT(identity,operation) DO UPDATE SET
      attempts=CASE WHEN window_start=excluded.window_start THEN attempts+1 ELSE 1 END,
      window_start=excluded.window_start`).bind(identity,operation,now).run();
  const row=await db.prepare('SELECT attempts FROM request_budgets WHERE identity=? AND operation=?').bind(identity,operation).first();
  return Number(row?.attempts||0)<=max;
}
export default {
  async fetch(request,env){
    const url=new URL(request.url);
    if(!url.pathname.startsWith('/api/')) return new Response('Not found',{status:404});
    if(!env.DB) return bad('database_unavailable',503);
    if(request.method==='OPTIONS') return new Response(null,{status:204});
    try{
      if(url.pathname==='/api/bootstrap'&&request.method==='GET'){
        const anonymousId=url.searchParams.get('anonymous_id')||'';
        if(!isId(anonymousId)) return bad('invalid_anonymous_id');
        const [counts,votes]=await Promise.all([
          env.DB.prepare('SELECT spot_id,recommend_count FROM spot_vote_counts').all(),
          env.DB.prepare('SELECT spot_id FROM anonymous_recommendations WHERE anonymous_id=?').bind(anonymousId).all()
        ]);
        return json({counts:counts.results||[],voted:(votes.results||[]).map(x=>x.spot_id)});
      }
      if(url.pathname==='/api/vote'&&request.method==='POST'){
        const p=await body(request);
        if(!p||!isId(p.spot_id)||!isId(p.anonymous_id)) return bad('invalid_payload');
        if(!(await budget(env.DB,p.anonymous_id,'vote',20))) return bad('rate_limit',429);
        const found=await env.DB.prepare('SELECT 1 AS ok FROM anonymous_recommendations WHERE spot_id=? AND anonymous_id=?').bind(p.spot_id,p.anonymous_id).first();
        let voted;
        if(found){
          await env.DB.prepare('DELETE FROM anonymous_recommendations WHERE spot_id=? AND anonymous_id=?').bind(p.spot_id,p.anonymous_id).run();
          voted=false;
        }else{
          await env.DB.prepare('INSERT OR IGNORE INTO anonymous_recommendations(spot_id,anonymous_id) VALUES(?,?)').bind(p.spot_id,p.anonymous_id).run();
          voted=true;
        }
        const count=await env.DB.prepare('SELECT recommend_count FROM spot_vote_counts WHERE spot_id=?').bind(p.spot_id).first();
        return json({voted,recommend_count:Number(count?.recommend_count||0)});
      }
      if(url.pathname==='/api/suggest'&&request.method==='POST'){
        const p=await body(request);
        if(!p||!isId(p.anonymous_id)) return bad('invalid_payload');
        if(!(await budget(env.DB,p.anonymous_id,'submission',3))) return bad('rate_limit',429);
        const allowedCategories=['sightseeing','gourmet','cycling','camp','onsen','michinoeki','stay','fishing','surfing','activity'];
        const allowedAreas=['kochi_city','east','west','north_niyodo'];
        if(!p.name?.trim()||!p.municipality?.trim()||!p.reason?.trim()||!allowedCategories.includes(p.category)||!allowedAreas.includes(p.area)) return bad('invalid_payload');
        const id=crypto.randomUUID();
        const details={...p}; delete details.anonymous_id; delete details.name; delete details.category; delete details.area; delete details.municipality; delete details.reason;
        await env.DB.prepare('INSERT INTO spot_suggestions(id,anonymous_id,name,category,area,municipality,reason,details) VALUES(?,?,?,?,?,?,?,?)')
          .bind(id,p.anonymous_id,p.name.trim().slice(0,300),p.category,p.area,p.municipality.trim().slice(0,300),p.reason.trim().slice(0,3000),JSON.stringify(details).slice(0,16000)).run();
        return json({ok:true,id,status:'pending'},201);
      }
      if(url.pathname==='/api/correction'&&request.method==='POST'){
        const p=await body(request);
        if(!p||!isId(p.anonymous_id)||!isId(p.spot_id)||!p.reason?.trim()) return bad('invalid_payload');
        if(!(await budget(env.DB,p.anonymous_id,'submission',3))) return bad('rate_limit',429);
        const targets=['営業時間','定休日','住所','電話','料金','駐車場','公式URL','店名/施設名','閉店/休業','写真','その他'];
        if(!targets.includes(p.target)) return bad('invalid_payload');
        const id=crypto.randomUUID();
        const details={...p}; delete details.anonymous_id; delete details.spot_id; delete details.target; delete details.reason;
        await env.DB.prepare('INSERT INTO spot_correction_requests(id,anonymous_id,spot_id,target,reason,details) VALUES(?,?,?,?,?,?)')
          .bind(id,p.anonymous_id,p.spot_id,p.target,p.reason.trim().slice(0,3000),JSON.stringify(details).slice(0,16000)).run();
        return json({ok:true,id,status:'pending'},201);
      }
      return bad('not_found',404);
    }catch(error){
      return json({error:'server_error'},500);
    }
  }
};
