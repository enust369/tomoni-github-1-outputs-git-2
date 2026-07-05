import { cp, mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { resolve } from "node:path";

const projectRoot = resolve(import.meta.dirname, "..");
const outputDir = resolve(projectRoot, "dist");

await rm(outputDir, { recursive: true, force: true });
await mkdir(outputDir, { recursive: true });
await cp(resolve(projectRoot, "index.html"), resolve(outputDir, "index.html"));
await cp(resolve(projectRoot, "supabase.js"), resolve(outputDir, "supabase.js"));

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
