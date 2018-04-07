class ApaPrijimatelia < ApplicationRecord
  def self.celkova_suma(meno, rok)
      where(meno_normalized: Normalizer.normalize_name(meno), rok: rok).sum(:suma)
  end
end
