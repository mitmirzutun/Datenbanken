-- assuming a fresh database, connected as postgres to postgres
-- you can drop database book to get a fresh start

\set ON_ERROR_STOP true

create database book;

\c book

create extension tablefunc;
create extension dict_xsyn;
create extension fuzzystrmatch;
create extension pg_trgm;
create extension cube;

create table countries(country_code char(2) primary key, country_name text unique);
insert into countries(country_code, country_name) values ('us', 'United States');
insert into countries(country_code, country_name) values ('mx', 'Mexico');
insert into countries(country_code, country_name) values ('au', 'Australia');
insert into countries(country_code, country_name) values ('gb', 'United Kingdom');
insert into countries(country_code, country_name) values ('de', 'Germany');
create table cities(name text not null, postal_code varchar(9) check (postal_code <> ''), country_code char(2) references countries, primary key (country_code, postal_code));
insert into cities values ('Portland', '97205', 'us');
insert into cities values ('Munich', '80689', 'de');
insert into cities values ('Munich', '80686', 'de');
create table venues(venue_id serial primary key, name varchar(255), street_address text, type char(7) check(type in ('public','private')) default 'public', postal_code varchar(9), country_code char(2), foreign key (country_code, postal_code) references cities(country_code,postal_code) match full);
insert into venues(name,postal_code,country_code) values ('Crystal Ballroom','97205','us');
insert into venues(name,postal_code,country_code) values ('Voodoo Donuts','97205','us');
insert into venues(name,street_address,postal_code,country_code) values ('My Place','Laimer Platz','80689','de');
create table events(title text, starts timestamp, ends timestamp, venue_id integer references venues, event_id serial primary key);
insert into events (title, starts, ends, venue_id) values ('LARP Club', '2012-02-15 17:30:00', '2012-02-15 19:30:00', 2);
insert into events (title, starts, ends) values ('April Fools Day', '2012-04-01 00:00:00', '2012-04-01 23:59:00');
insert into events (title, starts, ends) values ('Christmas', '2012-12-25 00:00:00', '2012-12-25 23:59:00');
insert into events (title, starts, ends, venue_id) values ('Moby', '2012-02-06 21:00:00', '2012-02-06 23:00:00', (select venue_id from venues where name='Crystal Ballroom'));
insert into events (title, starts, ends, venue_id) values ('Wedding', '2012-02-26 21:00:00', '2012-02-26 23:00:00', (select venue_id from venues where name='Voodoo Donuts'));
insert into events (title, starts, ends, venue_id) values ('Dinner with Mom', '2012-02-26 18:00:00', '2012-02-26 20:30:00', (select venue_id from venues where name='My Place'));
insert into events (title, starts, ends) values ('Valentine''s Day', '2012-02-14 00:00:00', '2012-02-14 23:59:00');
select relname from pg_class where relnamespace='2200' and relkind='r';
select c.country_name from countries c right join (select v.country_code from venues v left join events e on v.venue_id=e.venue_id where e.title='LARP Club') as v on v.country_code=c.country_code;
alter table venues add active boolean default 't';
select count(title) from events where title like '%Day%';
select min(starts), max(ends) from events inner join venues on events.venue_id=venues.venue_id where venues.name='Crystal Ballroom';
select venue_id, count(*) from events group by venue_id;
select venues.name, count(*) from events left join venues on venues.venue_id=events.venue_id group by venues.name;
select venue_id from events group by venue_id having count(*) >=2 and venue_id is not null;
select venue_id from events group by venue_id;
select distinct venue_id from events;
select venue_id, count(*) over (partition by venue_id) from events order by venue_id;
select venue_id, count(*) from events group by venue_id order by venue_id;

Create or replace function add_event(title text, starts timestamp, ends timestamp, venue text, postal varchar(9), country char(2))
returns boolean as $$
declare
  did_insert boolean:= false;
  found_count integer;
  the_venue_id integer;
begin
  select venue_id into the_venue_id from venues v where v.postal_code=postal and v.country_code=country and v.name Ilike venue limit 1;
  if the_venue_id is null then
    insert into venues (name,postal_code,country_code) values (venue, postal, country) returning venue_id Into the_venue_id;
    did_insert := true;
  end if;
  RAise Notice 'Venue found %', the_venue_id;
  insert into events (Title, starts, ends, venue_id) values (title,starts,ends,the_venue_id);
  return did_insert;
end;
$$ Language plpgsql;

select add_event('House Party', '2012-05-03 23:00', '2012-05-04 02:00', 'Run''s house', '97205','us');
select add_event('House Party', '2012-05-03 23:00', '2012-05-04 02:00', 'Run''s house', '97205','us');
create table logs(event_id integer,old_title varchar(255), old_starts timestamp,old_ends timestamp, logged_at timestamp Default current_timestamp);


create or replace function log_event() returns trigger as $$
declare
begin
  insert into logs(event_id,old_title,old_starts,old_ends) values (old.event_id,old.title,old.starts,old.ends);
  raise notice 'Someone just changed event #%', old.event_id;
  return new;
end;
$$ Language plpgsql;

create trigger log_events after update on events for each row execute procedure log_Event();
update events set ends='2012-05-04 01:00:00' whcreateere title='House Party';
create view holidays as select event_id as holiday_id, title as name, starts as date from events where title like '%Day%' and venue_id is null;
select name, to_char(date, 'Month DD, YYYY') as date from holidays where date<= '2012-04-01';
Alter table events add colors text array;
create or replace view holidays as select event_id as holiday_id, title as name, starts as date, colors from events where title like '%Day%' and venue_id is null;
update holidays set colors = '{"red", "green"}' where name='Christmas Day';
create or replace table month_count(month int);
insert into month_count values (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);
select * from crosstab('select extract(year from starts) as year, extract(month from starts) as month, count(*) from events group by year,month order by year,month','Select * from month_count') as (year int, jan int, feb int, mar int, apr int, may int, jun int, jul int, aug int, sep int, oct int, nov int, dec int) order by year;
