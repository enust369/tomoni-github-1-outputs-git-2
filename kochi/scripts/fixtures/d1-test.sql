-- Local integration-test fixture only. Not a production migration.
-- Models the table/column contract consumed by the unchanged D1 Worker.
CREATE TABLE anonymous_recommendations(spot_id TEXT NOT NULL,anonymous_id TEXT NOT NULL,PRIMARY KEY(spot_id,anonymous_id));
CREATE VIEW spot_vote_counts AS SELECT spot_id,count(*) AS recommend_count FROM anonymous_recommendations GROUP BY spot_id;
CREATE TABLE request_budgets(identity TEXT,operation TEXT,window_start INTEGER,attempts INTEGER,PRIMARY KEY(identity,operation));
CREATE TABLE spot_suggestions(id TEXT PRIMARY KEY,anonymous_id TEXT,name TEXT,category TEXT,area TEXT,municipality TEXT,reason TEXT,details TEXT,status TEXT NOT NULL DEFAULT 'pending');
CREATE TABLE spot_correction_requests(id TEXT PRIMARY KEY,anonymous_id TEXT,spot_id TEXT,target TEXT,reason TEXT,details TEXT,status TEXT NOT NULL DEFAULT 'pending');
