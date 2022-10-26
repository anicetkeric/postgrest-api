CREATE SCHEMA rest;

SET search_path TO api;

drop table if exists rest.author;
drop table if exists rest.book;

create table rest.author (
    id serial primary key,
    firstname character varying(255) COLLATE pg_catalog."default",
    lastname character varying(255) COLLATE pg_catalog."default"
);

create table rest.book (
    id serial primary key,
    description text,
    isbn character varying(255) COLLATE pg_catalog."default",
    page integer NOT NULL,
    price double precision NOT NULL,
    title character varying(100) COLLATE pg_catalog."default",
    author_id integer not null references rest.author(id)
);


-- Create User-Group Roles

-- grant anonymous role access to certain tables etc
CREATE ROLE anonymous nologin;
CREATE ROLE webuser nologin;

-- creation of the authenticator role
CREATE ROLE authenticator WITH NOINHERIT LOGIN PASSWORD 'vfx44M4$l$Fu';

GRANT anonymous TO authenticator;
GRANT webuser TO authenticator;

GRANT USAGE on SCHEMA rest to anonymous;
GRANT SELECT on rest.author to anonymous;
GRANT SELECT on rest.book to anonymous;

GRANT ALL on SCHEMA rest to webuser;
GRANT ALL on rest.author to webuser;
GRANT ALL on rest.book to webuser;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA rest TO webuser;
