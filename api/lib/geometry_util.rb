class GeometryUtil
  def self.wgs_to_jtsk(latitude, longitude)
    result = ActiveRecord::Base.connection.raw_connection.exec_params("
      SELECT
        ST_X(
          ST_Transform(
              ST_SetSRID(ST_MakePoint($1, $2), 4326), 3857)) as x,
        ST_Y(
          ST_Transform(
              ST_SetSRID(ST_MakePoint($3, $4), 4326), 3857)) as y
      ", [longitude, latitude, longitude, latitude])

    return {x: result.first['x'], y: result.first['y']}
  end
end
