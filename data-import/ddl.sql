-- DROP TABLE apa_ziadosti_o_projektove_podpory;
CREATE TABLE IF NOT EXISTS apa_ziadosti_o_projektove_podpory (
  id                       SERIAL,
  ziadatel                 TEXT,
  ico                      TEXT,
  kod_projektu             TEXT,
  nazov_projektu           TEXT,
  vuc                      TEXT,
  cislo_vyzvy              TEXT,
  kod_podopatrenia         TEXT,
  status                   TEXT,
  datum_zastavenia_konania TIMESTAMP,
  dovod_zastavenie_konania TEXT,
  datum_ucinnosti_zmluvy   TIMESTAMP,
  schvaleny_nfp_celkom     DECIMAL,
  vyplateny_nfp_celkom     DECIMAL,
  pocet_bodov              INTEGER
);

-- DROP TABLE apa_prijimatelia;
CREATE TABLE IF NOT EXISTS apa_prijimatelia (
  id                       SERIAL PRIMARY KEY,
  url                      TEXT,
  meno                     TEXT,
  psc                      TEXT,
  obec                     TEXT,
  opatrenie                TEXT,
  opatrenie_kod            TEXT,
  suma                     DECIMAL,
  rok                      INTEGER,
  meno_normalized          TEXT
);

-- DROP TABLE apa_ziadosti_o_priame_podpory;
CREATE TABLE IF NOT EXISTS apa_ziadosti_o_priame_podpory (
  id                       SERIAL PRIMARY KEY,
  url                      TEXT,
  ziadatel                 TEXT,
  ico                      TEXT,
  rok                      INTEGER,
  ziadosti                 TEXT
);

-- DROP TABLE apa_ziadosti_o_priame_podpory_diely;
CREATE TABLE IF NOT EXISTS apa_ziadosti_o_priame_podpory_diely (
  id                       SERIAL PRIMARY KEY,
  url                      TEXT,
  ziadatel                 TEXT,
  ico                      TEXT,
  rok                      INTEGER,
  lokalita                 TEXT,
  diel                     TEXT,
  kultura                  TEXT,
  vymera                   DECIMAL,
  ziadatel_normalized      TEXT
);

-- DROP TABLE crp_projekty;
CREATE TABLE IF NOT EXISTS crp_projekty (
  id                       SERIAL,
  url                      TEXT,
  nazov                    TEXT,
  datum_zverejnenia        TIMESTAMP,
  datum_zacatia            TIMESTAMP,
  datum_ukoncenia          TIMESTAMP,
  prijimatel               TEXT,
  ico_prijmatela           TEXT,
  miesto_realizacie        TEXT,
  poskytovatel             TEXT,
  typ_poskytnutej_pomoci   TEXT,
  crp_id                   TEXT,
  vyska_pomoci             TEXT,
  vyska_pomoci_num         DECIMAL
);

-- DROP TABLE crp_zmluvy;
CREATE TABLE IF NOT EXISTS crp_zmluvy (
  id                       SERIAL,
  crp_id                   TEXT,
  url                      TEXT,
  nazov                    TEXT,
  obstaravatel_nazov       TEXT,
  obstaravatel_ic          TEXT,
  dodavatel_nazov          TEXT,
  dodavatel_ico            TEXT,
  dodavatel_adresa         TEXT,
  nazov_zmluvy             TEXT,
  datum_uzavretia          TIMESTAMP,
  datum_ucinnosti          TIMESTAMP,
  poznamka_k_ucinnosti     TEXT,
  datum_platnosti          TIMESTAMP,
  suma_s_dph               TEXT,
  poznamka                 TEXT,
  prilohy_url              TEXT,
  prilohy_nazvy            TEXT,
  prilohy_subory           TEXT,
  interne_id               TEXT,
  datum_zverejnenia        TIMESTAMP,
  stav                     TEXT
);

CREATE TABLE IF NOT EXISTS finstat (
  id                       SERIAL PRIMARY KEY,
  ico                      TEXT,
  nazov                    TEXT,
  hlavna_cinnost           TEXT,
  sk_nace                  TEXT,
  datum_vzniku             TEXT,
  datum_zaniku             TEXT,
  dlhy                     BOOLEAN,
  zamestnanci              TEXT,
  zamestnanci_presny_pocet TEXT,
  adresa                   TEXT,
  mesto                    TEXT,
  okres                    TEXT,
  kraj                     TEXT,
  statutari                TEXT,
  trzby_2017               decimal,
  trzby_vynosy_2017        decimal,
  zisk_2017                decimal,
  aktiva_2017              decimal,
  zamestnanci_2017         TEXT,
  trzby_2016               decimal,
  trzby_vynosy_2016        decimal,
  zisk_2016                decimal,
  aktiva_2016              decimal,
  zamestnanci_2016         TEXT,
  trzby_2015               decimal,
  trzby_vynosy_2015        decimal,
  zisk_2015                decimal,
  aktiva_2015              decimal,
  zamestnanci_2015         TEXT,
  trzby_2014               decimal,
  trzby_vynosy_2014        decimal,
  zisk_2014                decimal,
  aktiva_2014              decimal,
  zamestnanci_2014         TEXT,
  trzby_2013               decimal,
  trzby_vynosy_2013        decimal,
  zisk_2013                decimal,
  aktiva_2013              decimal,
  zamestnanci_2013         TEXT,
  trzby_2012               decimal,
  trzby_vynosy_2012        decimal,
  zisk_2012                decimal,
  aktiva_2012              decimal,
  zamestnanci_2012         TEXT,
  trzby_2011               decimal,
  trzby_vynosy_2011        decimal,
  zisk_2011                decimal,
  aktiva_2011              decimal,
  zamestnanci_2011         TEXT,
  trzby_2010               decimal,
  trzby_vynosy_2010        decimal,
  zisk_2010                decimal,
  aktiva_2010              decimal,
  zamestnanci_2010         TEXT,
  trzby_2009               decimal,
  trzby_vynosy_2009        decimal,
  zisk_2009                decimal,
  aktiva_2009              decimal,
  zamestnanci_2009         TEXT
);

CREATE TABLE slovakia_addresses (
  id                  SERIAL,
  street              TEXT,
  number              TEXT,
  unit                TEXT,
  city                TEXT,
  district            TEXT,
  region              TEXT,
  postcode            TEXT,
  hash                TEXT,
  location            GEOGRAPHY(POINT)
);

-- DROP TABLE prijimatelia_finstat;
CREATE TABLE IF NOT EXISTS prijimatelia_finstat (
  id                   SERIAL PRIMARY KEY,
  prijimatelia_id      INTEGER REFERENCES apa_prijimatelia (id),
  finstat_id           INTEGER REFERENCES finstat (id)
);

-- DROP TABLE prijimatelia_ziadosti_o_priame_podpory;
CREATE TABLE IF NOT EXISTS prijimatelia_ziadosti (
  id                  SERIAL PRIMARY KEY,
  prijimatelia_id     INTEGER REFERENCES apa_prijimatelia (id),
  ziadosti_id         INTEGER REFERENCES apa_ziadosti_o_priame_podpory_diely (id)
);
