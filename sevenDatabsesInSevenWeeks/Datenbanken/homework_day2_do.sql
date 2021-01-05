/* create a rule that caputres DELTEs on venues and instead sets the active flag to FALSE. */

create rule not_delete_set_inactive as on delete to venues do instead update venues set active = false where name = OLD.name;
select * from venues;
delete from venues where name = 'Crystal Ballroom';
select * from venues;

/* The generate_series(a,b) function return a set of records, from a to b. Replace the mounth_count table SELECT with this. */

select * from generate_series(1,12);
Select * from crosstab('select extract(year from starts) as year, extract(month from starts) as month, count(*) from events group by year, month order by year, month', 'select * from generate_series(1,12)') as (year int, jan int, feb int, mar int, apr int, may int, jun int, jul int, aug int, sep int, oct int, nov int, dec int) order by year; 

