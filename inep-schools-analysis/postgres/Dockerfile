FROM postgres:13

COPY ./raw/escolas_inep.csv /tmp/escolas_inep.csv
COPY ./postgres/init.sql /docker-entrypoint-initdb.d/init.sql
