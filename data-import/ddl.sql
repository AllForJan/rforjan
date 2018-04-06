-- DROP TABLE apa_ziadosti_projektove_podpory;
CREATE TABLE IF NOT EXISTS apa_ziadosti_projektove_podpory (
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
  id                       SERIAL,
  url                      TEXT,
  meno                     TEXT,
  psc                      TEXT,
  obec                     TEXT,
  opatrenie                TEXT,
  opatrenie_kod            TEXT,
  suma                     DECIMAL,
  rok                      INTEGER
);

-- DROP TABLE apa_ziadosti_projektove_podpory;
CREATE TABLE IF NOT EXISTS apa_ziadosti_o_priame_podpory (
  id                       SERIAL,
  ziadatel                 TEXT,
  url                      TEXT,
  ico                      TEXT,
  rok                      INTEGER,
  ziadosti                 TEXT
);
