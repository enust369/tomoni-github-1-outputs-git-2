import {mkdir,writeFile,copyFile,rm,cp} from 'node:fs/promises';
import {resolve} from 'node:path';
import {render,getRoutes} from '../render.mjs';
import {loadContent} from '../content.mjs';
if(process.env.KOCHI_SUPABASE_URL)await loadContent(process.env.KOCHI_SUPABASE_URL,process.env.KOCHI_SUPABASE_ANON_KEY);
const routes=getRoutes();
const root=resolve(import.meta.dirname,'..'),out=resolve(root,'dist');
const origin=process.env.KOCHI_SITE_URL||'';
if(origin&&!/^https:\/\/[^/]+\/?$/.test(origin))throw new Error('KOCHI_SITE_URL must be an https origin');
await rm(out,{recursive:true,force:true});await mkdir(out,{recursive:true});
for(const f of ['styles.css','app.mjs','data.mjs','render.mjs','content.mjs','photos.mjs','favicon.svg'])await copyFile(resolve(root,f),resolve(out,f));
await cp(resolve(root,'assets/photos'),resolve(out,'assets/photos'),{recursive:true});
await writeFile(resolve(out,'config.js'),`window.KOCHI_CONFIG=${JSON.stringify({supabaseUrl:process.env.KOCHI_SUPABASE_URL||'',supabaseAnonKey:process.env.KOCHI_SUPABASE_ANON_KEY||'',siteUrl:origin})};`);
for(const path of routes){const dir=resolve(out,'.'+path);await mkdir(dir,{recursive:true});await writeFile(resolve(dir,'index.html'),render(path,origin).html)}
await writeFile(resolve(out,'404.html'),render('/not-found/',origin).html);
await writeFile(resolve(out,'robots.txt'),origin?`User-agent: *\nAllow: /\nSitemap: ${origin.replace(/\/$/,'')}/sitemap.xml\n`:'User-agent: *\nDisallow: /\n');
if(origin)await writeFile(resolve(out,'sitemap.xml'),'<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'+routes.filter(p=>!p.includes('sample-')&&!['/search/','/login/','/mypage/'].includes(p)).map(p=>`<url><loc>${new URL(p,origin).href}</loc></url>`).join('')+'</urlset>');
console.log(`Built ${routes.length} routes in kochi/dist (preview: ${!origin})`);
