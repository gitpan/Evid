DROP TABLE IF EXISTS `subject_group`;
DROP TABLE IF EXISTS `subject`;
DROP TABLE IF EXISTS `group`;
DROP TABLE IF EXISTS `dashboard`;
DROP TABLE IF EXISTS `scoreboard`;
DROP TABLE IF EXISTS `user_site`;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS `history`;

CREATE TABLE `group` (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE
);

CREATE TABLE `dashboard` (
    `id`        INTEGER PRIMARY KEY AUTOINCREMENT,
    `site`      TEXT,
    `group`     TEXT,
    `group_idx` INTEGER,
    `enrolled`  INTEGER DEFAULT 0,
    `complete`  INTEGER DEFAULT 0,
    UNIQUE (`site`, `group`, `group_idx`)
);

CREATE TABLE `user` (
    username TEXT PRIMARY KEY,
    email    TEXT,
    timezone TEXT
);

CREATE TABLE `user_site` (
    username TEXT UNIQUE,
    sitename TEXT,
    PRIMARY KEY(username, sitename),
    FOREIGN KEY(username) REFERENCES `user`(username)
);

CREATE TABLE `subject` (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    sitename   TEXT,
    idx        INTEGER,
    username   TEXT,
    created_at TEXT,
    data       TEXT,
    FOREIGN KEY(username) REFERENCES `user`(username)
);

CREATE TABLE `subject_group` (
    subject_id  INTEGER,
    group_id    INTEGER,
    idx         INTEGER,
    timestamp   TEXT,
    PRIMARY KEY(subject_id, group_id, idx),
    FOREIGN KEY(subject_id) REFERENCES `subject`(id),
    FOREIGN KEY(group_id)   REFERENCES `group`(id)
);

CREATE TABLE `scoreboard` (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    subject_id INTEGER UNIQUE,
    data       TEXT,
    FOREIGN KEY(subject_id) REFERENCES `subject`(id)
);

CREATE TABLE `history` (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    username    TEXT,
    sitename    TEXT,
    action      TEXT,
    link_target TEXT,
    label       TEXT,
    timestamp   TEXT,
    FOREIGN KEY(username) REFERENCES `user`(username)
);

CREATE INDEX `history_idx01` ON `history`(`sitename`);
CREATE INDEX `history_idx02` ON `history`(`timestamp`);
