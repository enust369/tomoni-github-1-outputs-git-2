// Search visibility stays off until the public information is ready.
export const DEFAULT_SITE_ORIGIN='https://kochi-kanko-ranking.iriehair.workers.dev';
export const nonIndexablePaths=new Set(['/search/','/login/','/mypage/']);
export const isIndexablePath=path=>!nonIndexablePaths.has(path)&&!path.includes('sample-');
export const isSearchIndexingEnabled=value=>value==='true';
