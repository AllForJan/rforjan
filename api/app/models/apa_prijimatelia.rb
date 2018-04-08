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

  def self.get_distance_stats
    query = "select meno_normalized, avg(distance) as average_distance, max(distance) as max_distance, ST_AsGeoJSON(prijimatel_location) as location
    from
      (select entities.*, diely.lokalita, diely.diel, st_distance(st_centroid(parts_2016.geom), slovakia_addresses.location) as distance, slovakia_addresses.location as prijimatel_location from
        (SELECT meno_normalized, rok, obec FROM apa_prijimatelia GROUP BY meno_normalized, rok, obec) as entities
      LEFT JOIN apa_ziadosti_o_priame_podpory_diely as diely ON diely.ziadatel_normalized = entities.meno_normalized AND diely.rok = entities.rok
      LEFT JOIN parts_2016 ON diely.lokalita = parts_2016.location AND diely.diel = parts_2016.part
      LEFT JOIN slovakia_addresses ON entities.obec = slovakia_addresses.city AND slovakia_addresses.street = 'center'
      WHERE diely.rok = '2016') as distances
    WHERE distance IS NOT NULL
    group by meno_normalized, prijimatel_location order by average_distance desc"

    result = ActiveRecord::Base.connection.raw_connection.exec_params(query,[])
  end
end
