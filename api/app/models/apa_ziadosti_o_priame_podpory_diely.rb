class ApaZiadostiOPriamePodporyDiely < ApplicationRecord
  self.table_name='apa_ziadosti_o_priame_podpory_diely'

  def self.celkova_vymera(meno, rok)
    where(ziadatel_normalized: Normalizer.normalize_name(meno), rok: rok).sum(:vymera)
  end

  def self.pocet_ziadosti(meno, rok)
    where(ziadatel_normalized: Normalizer.normalize_name(meno), rok: rok).count
  end
end