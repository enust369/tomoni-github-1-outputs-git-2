import { cp, mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { resolve } from "node:path";

const projectRoot = resolve(import.meta.dirname, "..");
const outputDir = resolve(projectRoot, "dist");

await rm(outputDir, { recursive: true, force: true });
await mkdir(outputDir, { recursive: true });

const sourceIndex = await readFile(resolve(projectRoot, "index.html"), "utf8");
const seoMeta = `
  <meta name="description" content="TOMONIは、地域で同性同士が気軽につながり、一緒に過ごせる時間を見つけるためのサービスです。">
  <link rel="canonical" href="https://tomoni-app.com/">
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="TOMONI">
  <meta property="og:title" content="TOMONI｜同性同士で気軽に会える時間をつくるサービス">
  <meta property="og:description" content="地域で同性同士が気軽につながり、一緒に過ごせる時間を見つけるためのサービスです。">
  <meta property="og:url" content="https://tomoni-app.com/">
  <meta property="og:image" content="https://tomoni-app.com/assets/brand/app-icon-1024x1024.png">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="TOMONI｜同性同士で気軽に会える時間をつくるサービス">
  <meta name="twitter:description" content="地域で同性同士が気軽につながり、一緒に過ごせる時間を見つけるためのサービスです。">
  <meta name="twitter:image" content="https://tomoni-app.com/assets/brand/app-icon-1024x1024.png">
`;
const builtIndex = sourceIndex.includes('rel="canonical"')
  ? sourceIndex
  : sourceIndex.replace("  <title>", `${seoMeta}  <title>`);
await writeFile(resolve(outputDir, "index.html"), builtIndex);

await cp(resolve(projectRoot, "supabase.js"), resolve(outputDir, "supabase.js"));
await cp(resolve(projectRoot, "assets"), resolve(outputDir, "assets"), { recursive: true });
await cp(resolve(projectRoot, "40s-friends"), resolve(outputDir, "40s-friends"), { recursive: true });
await cp(resolve(projectRoot, "site.webmanifest"), resolve(outputDir, "site.webmanifest"));
try {
  await cp(resolve(projectRoot, "_headers"), resolve(outputDir, "_headers"));
} catch {}
await cp(resolve(projectRoot, "sitemap.xml"), resolve(outputDir, "sitemap.xml"));
await cp(resolve(projectRoot, "robots.txt"), resolve(outputDir, "robots.txt"));

let fileEnv = {};
try {
  const source = await readFile(resolve(projectRoot, ".env"), "utf8");
  fileEnv = Object.fromEntries(source.split(/\r?\n/).filter((line) => line && !line.startsWith("#") && line.includes("=")).map((line) => {
    const separator = line.indexOf("=");
    return [line.slice(0, separator).trim(), line.slice(separator + 1).trim().replace(/^['"]|['"]$/g, "")];
  }));
} catch {}

const publicEnv = {
  VITE_SUPABASE_URL: process.env.VITE_SUPABASE_URL || fileEnv.VITE_SUPABASE_URL || "",
  VITE_SUPABASE_ANON_KEY: process.env.VITE_SUPABASE_ANON_KEY || fileEnv.VITE_SUPABASE_ANON_KEY || "",
};

await writeFile(resolve(outputDir, "supabase-env.js"), `window.__TOMONI_ENV__ = ${JSON.stringify(publicEnv, null, 2)};\n`);

console.log("Built TOMONI to dist/");
