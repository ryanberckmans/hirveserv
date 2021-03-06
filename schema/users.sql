CREATE TABLE IF NOT EXISTS users (
	userid INTEGER PRIMARY KEY,
	name STRING UNIQUE NOT NULL,
	password STRING,
	isPending BOOLEAN DEFAULT 1
);

CREATE TABLE IF NOT EXISTS privs (
	userid INTEGER,
	priv STRING,
	FOREIGN KEY( userid ) REFERENCES users( userid ),
	UNIQUE( userid, priv ) ON CONFLICT IGNORE
);

CREATE TABLE IF NOT EXISTS settings (
	userid INTEGER,
	setting STRING NOT NULL,
	value STRING,
	FOREIGN KEY( userid ) REFERENCES users( userid ),
	UNIQUE( userid, setting ) ON CONFLICT REPLACE
);

CREATE TABLE IF NOT EXISTS ipauths (
	userid INTEGER,
	ip STRING NOT NULL,
	mask STRING DEFAULT "255.255.255.255",
	FOREIGN KEY( userid ) REFERENCES users( userid ),
	UNIQUE( userid, ip, mask ) ON CONFLICT IGNORE
);

CREATE INDEX IF NOT EXISTS idx_privs ON privs ( userid );
CREATE INDEX IF NOT EXISTS idx_settings ON settings ( userid );
CREATE INDEX IF NOT EXISTS idx_ipauths ON ipauths ( userid, ip );
