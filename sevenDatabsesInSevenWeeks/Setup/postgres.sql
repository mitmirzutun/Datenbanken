# in shell, do:
# > createdb book
# > psql book
# make sure you create the extension in the book database 


create extension tablefunc;
create extension dict_xsyn;
create extension fuzzystmatch;
create extension pg_trgm;
create extension cube;

