## to run docker reachabel for a tool like dbeaver or navicat:
docker run -p 5432:5432 --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres

## to clean and recreate everything, in database book, do:
```
\c postgres
drop database book
```

on command line:

```
docker cp chapter2.sql some-postgres:/tmp
```

back in db:

```
\i /tmp/chapter2.sql
```
