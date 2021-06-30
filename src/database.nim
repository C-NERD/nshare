import db_sqlite
from os import getAppDir

let db = open(getAppDir() & "database.db", "", "", "")

proc createSchema() =
    db.exec(sql"DROP TABLE IF EXISTS location;")
    db.exec(sql"DROP TABLE IF EXISTS extensions;")

    db.exec(sql"""
    CREATE TABLE IF NOT EXISTS location(
        id INTERGER NOT NULL,
        downloads TEXT,
        music TEXT,
        image TEXT,
        video TEXT,
        doc TEXT
    );
    """)

    db.exec(sql"""
    CREATE TABLE IF NOT EXISTS extensions(
        id INTERGER NOT NULL,
        music TEXT,
        image TEXT,
        video TEXT,
        doc TEXT
    );
    """)

    discard db.tryInsertID(sql"INSERT INTO location VALUES(?, ?, ?, ?, ?, ?);",
    $1, "", "", "", "", "")
    discard db.tryInsertID(sql"INSERT INTO extensions VALUES(?, ?, ?, ?, ?);",
    $1, "", "", "", "")

    