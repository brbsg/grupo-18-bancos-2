-- =========================================================
-- Idempotência (drop em ordem de dependência)
-- =========================================================
drop table if exists bridge_escola_etapa cascade;
drop table if exists fato_escola cascade;

drop table if exists dim_etapa cascade;
drop table if exists dim_restricao_atendimento cascade;
drop table if exists dim_porte cascade;
drop table if exists dim_dependencia cascade;
drop table if exists dim_localidade cascade;
drop table if exists dim_escola cascade;

-- =========================================================
-- DIMENSÕES
-- =========================================================

-- Escola (SCD1)
create table dim_escola (
  sk_escola      integer generated always as identity primary key,
  codigo_inep    text not null unique,
  nome_escola    text not null
);

comment on table dim_escola is 'Dimensão de escolas (cadastro estático).';
comment on column dim_escola.codigo_inep is 'Código INEP original (chave natural).';

-- Localidade (SCD1)
create table dim_localidade (
  sk_localidade  integer generated always as identity primary key,
  uf             text not null,
  municipio      text not null,
  regiao         text,
  localizacao    text,               -- urbana/rural/etc.
  is_rural       boolean not null,
  latitude       double precision,
  longitude      double precision,

  unique (uf, municipio, regiao, localizacao, is_rural, latitude, longitude)
);

comment on table dim_localidade is 'Dimensão de localização geográfica.';

-- Dependência administrativa (SCD1)
create table dim_dependencia (
  sk_dependencia   integer generated always as identity primary key,
  dependencia_adm  text not null,    -- Federal/Estadual/Municipal/Privada...
  is_publica       boolean not null,
  constraint uq_dim_dependencia unique (dependencia_adm, is_publica)
);

comment on table dim_dependencia is 'Dimensão de dependência administrativa.';

-- Porte (SCD1)
create table dim_porte (
  sk_porte        integer generated always as identity primary key,
  porte_escola    text not null,     -- Pequena/Média/Grande...
  porte_numerico  integer,
  constraint ck_dim_porte_num check (porte_numerico is null or porte_numerico >= 0),
  constraint uq_dim_porte unique (porte_escola, porte_numerico)
);

comment on table dim_porte is 'Dimensão de porte da escola.';

-- Restrição de atendimento (SCD1)
create table dim_restricao_atendimento (
  sk_restricao    integer generated always as identity primary key,
  restricao_desc  text not null unique
);

comment on table dim_restricao_atendimento is 'Dimensão de tipo de restrição de atendimento.';

-- Etapas/Modalidades (domínio)
create table dim_etapa (
  sk_etapa        integer generated always as identity primary key,
  etapa           text not null unique   -- EI, EF I, EF II, EM, EJA, etc.
);

comment on table dim_etapa is 'Dimensão de etapa/modalidade de ensino.';

-- =========================================================
-- FATO (1 linha por escola)
-- =========================================================
create table fato_escola (
  sk_escola       integer not null references dim_escola(sk_escola),
  sk_localidade   integer not null references dim_localidade(sk_localidade),
  sk_dependencia  integer not null references dim_dependencia(sk_dependencia),
  sk_porte        integer references dim_porte(sk_porte),
  sk_restricao    integer references dim_restricao_atendimento(sk_restricao),

  constraint pk_fato_escola primary key (sk_escola)
);

comment on table fato_escola is 'Fato com 1 linha por escola (snapshot estático).';

-- =========================================================
-- BRIDGE N:N (Escola × Etapas)
-- =========================================================
create table bridge_escola_etapa (
  sk_escola integer not null references dim_escola(sk_escola) on delete cascade,
  sk_etapa  integer not null references dim_etapa(sk_etapa),
  constraint pk_bridge_escola_etapa primary key (sk_escola, sk_etapa)
);

create index ix_bridge_etapa on bridge_escola_etapa(sk_etapa);

comment on table bridge_escola_etapa is 'Relação N:N entre escola e etapas/modalidades (base estática).';
