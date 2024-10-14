create table fish (
    id integer PRIMARY KEY AUTOINCREMENT NOT NULL,
    identity varchar(64) NOT NULL,
    count integer NOT NULL DEFAULT 1,
    fish_type varchar(16) NOT NULL,
    fish_data blob NOT NULL,
    desc text NOT NULL DEFAULT '',
    tags text NOT NULL DEFAULT '',
    is_marked tinyint NOT NUll DEFAULT 0,
    is_locked tinyint NOT NUll DEFAULT 0,
    extra_info text NOT NULL,
    create_time varchar(64) NOT NULL,
    update_time varchar(64) NOT NULL
);

create index idx__identity on fish (identity);
create index idx__update_time on fish (update_time);

create table fish_expired (
    id integer PRIMARY KEY NOT NULL,
    identity varchar(64) NOT NULL,
    count integer NOT NULL,
    fish_type varchar(16) NOT NULL,
    fish_data blob NOT NULL,
    desc text NOT NULL,
    tags text NOT NULL,
    is_marked tinyint NOT NUll,
    is_locked tinyint NOT NUll,
    extra_info text NOT NULL,
    create_time varchar(64) NOT NULL,
    update_time varchar(64) NOT NULL,
    expire_time varchar(64) NOT NULL
);
