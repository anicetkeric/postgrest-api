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

-- init data 
INSERT INTO rest.author (id,firstname,lastname)
VALUES
  (1,'Bree','Nasim'),
  (2,'Kessie','Brenden'),
  (3,'Willow','Kirby'),
  (4,'Lareina','Lunea'),
  (5,'Flavia','Zane'),
  (6,'Noah','Maxwell'),
  (7,'Kelsey','Clinton'),
  (8,'Gage','Marsden'),
  (9,'Perry','Elijah'),
  (10,'Kennedy','Clementine');
  
  INSERT INTO rest.book (id,description,isbn,page,price,title,author_id)
VALUES
  (1,'netus et malesuada','X4J 5H8',62,529,'arcu. Vestibulum ut',9),
  (2,'mollis non,','M3Q 4G1',15,668,'Nullam ut',2),
  (3,'Maecenas mi felis, adipiscing fringilla, porttitor','B5W 1Y8',16,708,'et ipsum cursus',5),
  (4,'eros turpis non enim. Mauris quis turpis','Q1O 7Y6',46,642,'Nulla tincidunt,',4),
  (5,'tellus non magna. Nam ligula elit, pretium','Q0V 7Q9',86,656,'purus, in',1),
  (6,'a, facilisis non, bibendum sed, est.','V6Q 8T2',57,299,'sagittis',3),
  (7,'suscipit nonummy. Fusce fermentum fermentum arcu. Vestibulum ante ipsum','Q2T 8C5',68,891,'ligula. Donec',8),
  (8,'arcu. Vivamus sit amet risus. Donec egestas.','R5E 3I4',14,455,'vel',6),
  (9,'pede, nonummy ut, molestie in, tempus','I0W 6N9',33,874,'lorem semper',8),
  (10,'sed consequat auctor, nunc nulla vulputate dui, nec','U4E 5V8',7,185,'vel arcu.',4);

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
