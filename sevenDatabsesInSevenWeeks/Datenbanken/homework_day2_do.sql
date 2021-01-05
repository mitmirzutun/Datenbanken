/* create a rule that caputres DELTEs on venues and instead sets the active flag to FALSE. */

create rule not_delete_set_inactive as on delete to venues do instead update venues set active = false where name = OLD.name;
select * from venues;
delete from venues where name = 'Crystal Ballroom';
select * from venues;

/* The generate_series(a,b) function return a set of records, from a to b. Replace the mounth_count table SELECT with this. */

select * from generate_series(1,12);
Select * from crosstab('select extract(year from starts) as year, extract(month from starts) as month, count(*) from events group by year, month order by year, month', 'select * from generate_series(1,12)') as (year int, jan int, feb int, mar int, apr int, may int, jun int, jul int, aug int, sep int, oct int, nov int, dec int) order by year; 

/* Build a pivot table that displays every day in a single month, where each week of the month is a row and each day name forms a column,. Each day should contain a count of the nuber of events for that date or sould remain blank oíf no event occurs. */ 

select * from crosstab('select extract(month from starts) as month, extract(dow from starts) as weekday, count(*) from events group by month, weekday','select generate_series(1,7)') as (month int, sun int, mon int, tue int, wed int, thu int, fri int, sat int);
