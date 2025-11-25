-- DDL for the 'escolas' table in the Silver layer.
-- This table stores cleaned and transformed data about Brazilian schools from INEP,
-- based on the processing done in the etl_raw_to_silver.ipynb notebook.

CREATE SCHEMA IF NOT EXISTS silver;
GRANT USAGE ON SCHEMA silver TO inep;
ALTER SCHEMA silver OWNER TO pg_database_owner;

CREATE TABLE IF NOT EXISTS silver.esc (
    cod_inep BIGINT PRIMARY KEY,
    nom_esc VARCHAR(255) NOT NULL,
    uf VARCHAR(2),
    mun VARCHAR(255),
    reg VARCHAR(50),
    lca VARCHAR(50),
    is_rur INTEGER, -- 1 for Rural, 0 for Urban
    dpd_adm VARCHAR(100),
    is_pub INTEGER, -- 1 for Public, 0 for Private
    prt_esc VARCHAR(100),
    prt_num INTEGER, -- 1 for Small, 2 for Medium, 3 for Large
    etp_mod TEXT,
    qtd_etp INTEGER DEFAULT 0,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    rst_atn VARCHAR(255)
);
