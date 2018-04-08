class ApaPrijimatelia < ApplicationRecord
  def self.celkova_suma(meno, rok)
      where(meno_normalized: Normalizer.normalize_name(meno), rok: rok).sum(:suma)
  end

  def self.get_address_for_ico(ico)
    result = ActiveRecord::Base
                 .connection
                 .raw_connection
                 .exec_params(
                     'select nazov, adresa, mesto, ST_AsText(location) as point, ST_AsGeoJSON(location) as point_json from finstat
                      LEFT JOIN slovakia_addresses ON
                        slovakia_addresses.city = finstat.mesto
                        AND finstat.adresa ILIKE CONCAT(slovakia_addresses.street, \'%\')
                      WHERE finstat.ico = $1
                      LIMIT 1',
            [ico])

    result.count == 1 ? result.first.to_h : nil
  end
end
