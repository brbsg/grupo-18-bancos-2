-- =========================================================
-- Schema
-- =========================================================
create schema if not exists dw;

-- =========================================================
-- Idempotência (drop em ordem de dependência)
-- =========================================================
drop table if exists dw.bridge_esc_etp cascade;
drop table if exists dw.fat_esc cascade;

drop table if exists dw.dim_etp cascade;
drop table if exists dw.dim_rst_atn cascade;
drop table if exists dw.dim_prt cascade;
drop table if exists dw.dim_dpd cascade;
drop table if exists dw.dim_loc cascade;
drop table if exists dw.dim_esc cascade;

-- =========================================================
-- DIMENSÕES
-- =========================================================

-- Escola (SCD1)
create table dw.dim_esc (
  srk_esc     integer generated always as identity primary key,
  cod_inep    text not null unique,
  nom_esc     text not null
);

comment on table dw.dim_esc is 'Dimensão de escolas (cadastro estático).';
comment on column dw.dim_esc.cod_inep is 'Código INEP original (chave natural).';

-- Localidade (SCD1)
create table dw.dim_loc (
  srk_loc     integer generated always as identity primary key,
  uf          text not null,
  mun         text not null,
  reg         text,
  lca         text,               -- urbana/rural/etc.
  is_rur      boolean not null,
  lat         double precision,
  lon         double precision,

  unique (uf, mun, reg, lca, is_rur, lat, lon)
);

comment on table dw.dim_loc is 'Dimensão de localização geográfica.';

-- Dependência administrativa (SCD1)
create table dw.dim_dpd (
  srk_dpd   integer generated always as identity primary key,
  dpd_adm   text not null,    -- Federal/Estadual/Municipal/Privada...
  is_pub    boolean not null,
  constraint uq_dim_dpd unique (dpd_adm, is_pub)
);

comment on table dw.dim_dpd is 'Dimensão de dependência administrativa.';

-- Porte (SCD1)
create table dw.dim_prt (
  srk_prt    integer generated always as identity primary key,
  prt_esc    text not null,     -- Pequena/Média/Grande...
  prt_num    integer,
  constraint ck_dim_prt_num check (prt_num is null or prt_num >= 0),
  constraint uq_dim_prt unique (prt_esc, prt_num)
);

comment on table dw.dim_prt is 'Dimensão de porte da escola.';

-- Restrição de atendimento (SCD1)
create table dw.dim_rst_atn (
  srk_rst    integer generated always as identity primary key,
  rst_desc   text not null unique
);

comment on table dw.dim_rst_atn is 'Dimensão de tipo de restrição de atendimento.';

-- Etapas/Modalidades (domínio)
create table dw.dim_etp (
  srk_etp     integer generated always as identity primary key,
  etp         text not null unique   -- EI, EF I, EF II, EM, EJA, etc.
);

comment on table dw.dim_etp is 'Dimensão de etapa/modalidade de ensino.';

-- =========================================================
-- FATO (1 linha por escola)
-- =========================================================
create table dw.fat_esc (
  srk_esc    integer not null references dw.dim_esc(srk_esc),
  srk_loc    integer not null references dw.dim_loc(srk_loc),
  srk_dpd    integer not null references dw.dim_dpd(srk_dpd),
  srk_prt    integer references dw.dim_prt(srk_prt),
  srk_rst    integer references dw.dim_rst_atn(srk_rst),

  constraint pk_fat_esc primary key (srk_esc)
);

comment on table dw.fat_esc is 'Fato com 1 linha por escola (snapshot estático).';

-- =========================================================
-- BRIDGE N:N (Escola × Etapas)
-- =========================================================
create table dw.bridge_esc_etp (
  srk_esc integer not null references dw.dim_esc(srk_esc) on delete cascade,
  srk_etp integer not null references dw.dim_etp(srk_etp),
  constraint pk_bridge_esc_etp primary key (srk_esc, srk_etp)
);

create index ix_bridge_etp on dw.bridge_esc_etp(srk_etp);

comment on table dw.bridge_esc_etp is 'Relação N:N entre escola e etapas/modalidades (base estática).';