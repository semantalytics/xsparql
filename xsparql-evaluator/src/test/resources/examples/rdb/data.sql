
DROP TABLE IF EXISTS Addresses CASCADE;
CREATE TABLE Addresses (
  ID serial primary key,
  city text,
  state text
) ;
INSERT INTO Addresses VALUES (18,'Cambridge','MA');



DROP TABLE IF EXISTS Ppl;
CREATE TABLE Ppl (
  ID integer primary key,
  fname text,
  addr integer references Addresses(ID)
) ;
INSERT INTO Ppl VALUES (7,'Bob',18),(8,'Sue',NULL);


DROP TABLE IF EXISTS student CASCADE;
CREATE TABLE student (
  id serial primary key,
  name text
) ;
INSERT INTO student VALUES (1,'Nuno'),(2,'Stefan'),(3,'Axel'),(4,NULL);



DROP TABLE IF EXISTS address;
CREATE TABLE address (
  id serial primary key,
  address text,
  student integer references student (id)
) ;
INSERT INTO address VALUES (1,'galway 1',1),(2,'galway 2',2),(3,NULL,3);


DROP TABLE IF EXISTS band;
CREATE TABLE band (
  id serial primary key, 
  name text,
  origin text
) ;
INSERT INTO band VALUES (1,'U2','Dublin'),(2,'blind guardian','germany');



DROP TABLE IF EXISTS parent CASCADE;
CREATE TABLE parent (
  id integer primary key
) ;
INSERT INTO parent VALUES (1);


DROP TABLE IF EXISTS child;
CREATE TABLE child (
  id integer,
  parent_id integer references parent (id) on delete cascade
) ;
INSERT INTO child VALUES (1,1);


DROP TABLE IF EXISTS child2;
CREATE TABLE child2 (
  id1 integer,
  id2 integer,
  parent_id integer,
  primary key (id1,id2)
) ;
INSERT INTO child2 VALUES (1,1,1),(1,2,1);


-- DROP SCHEMA IF EXISTS bands;
-- CREATE SCHEMA bands;

-- DROP TABLE IF EXISTS bands.person;
-- CREATE TABLE bands.person (
--   ssn integer,
--   name text,
--   memberOf integer
-- ) ;
-- INSERT INTO bands.person VALUES (1,'Bono',1),(123,'hansi',2);



DROP TABLE IF EXISTS topArtists;
CREATE TABLE topArtists (
  artist text,
  rank integer
) ;
INSERT INTO topArtists VALUES ('Therion',1),('Nightwish',2),('Blind Guardian',3),('Rhapsody of Fire',4),('Iced Earth',5);

