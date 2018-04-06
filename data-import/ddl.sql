CREATE TABLE IF NOT EXISTS apa_ziadosti_projektove_podpory (
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
