class ApaZiadostiOPriamePodporyDiely < ApplicationRecord
  self.table_name='apa_ziadosti_o_priame_podpory_diely'

  def self.celkova_vymera(meno, rok)
    where(ziadatel_normalized: Normalizer.normalize_name(meno), rok: rok).sum(:vymera)
  end

  def self.pocet_ziadosti(meno, rok)
    where(ziadatel_normalized: Normalizer.normalize_name(meno), rok: rok).count
  end

  def self.pocet_dielov(meno, rok)
    where(ziadatel_normalized: Normalizer.normalize_name(meno), rok: rok,).count('distinct(diel, lokalita)')
  end

  def vymera_dielu(rok)
    return unless rok == 2016
    Parts_2016.select(:area).find_by(part: diel, location: lokalita)&.area
  end

  def self.vzdialenosti(ico, location, rok)
    return unless rok == 2016
    ActiveRecord::Base.connection.raw_connection.exec_params(
        'SELECT *,
           ST_Distance(st_centroid(parts_2016.geom), ST_GeographyFromText($1)) as distance
        FROM apa_ziadosti_o_priame_podpory_diely
        LEFT JOIN parts_2016 ON parts_2016.location = apa_ziadosti_o_priame_podpory_diely.lokalita AND parts_2016.part = apa_ziadosti_o_priame_podpory_diely.diel
        WHERE rok = $3 and "ico" = $2
        ORDER BY distance DESC',
        [location, ico, rok])
  end

end
