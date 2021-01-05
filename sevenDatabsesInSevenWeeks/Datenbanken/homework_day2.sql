/* create a rule that caputres DELTEs on venues and instead sets the active flag to FALSE. */

create rule not_delete_set_inactive as on delete to venues do instead update venues set active = false where name = OLD.name;
select * from venues;
delete from venues where name = 'Crystal Ballroom';
select * from venues;
