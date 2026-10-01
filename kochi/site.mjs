import {spots,categories} from './data.mjs';

// Search visibility stays off until the public information is ready.
export const DEFAULT_SITE_ORIGIN='https://kochi-kanko-ranking.iriehair.workers.dev';
export const nonIndexablePaths=new Set(['/search/','/mypage/']);
const emptyCategoryPaths=new Set(Object.keys(categories).filter(category=>!spots.some(spot=>spot.category===category&&spot.is_published!==false)).map(category=>`/${category}/`));
export const isIndexablePath=path=>!nonIndexablePaths.has(path)&&!emptyCategoryPaths.has(path)&&!path.includes('sample-');
export const isSearchIndexingEnabled=value=>value==='true';
