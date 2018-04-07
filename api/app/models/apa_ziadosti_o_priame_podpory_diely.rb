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
end
