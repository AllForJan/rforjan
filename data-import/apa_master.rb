require_relative 'dbconn'

$conn = db_connection

prijimatelia = $conn.exec('select * from apa_prijimatelia').to_a
ziadosti = $conn.exec('select * from apa_ziadosti_o_priame_podpory_diely').to_a


prijimatelia.each do
  prijimatelia['meno_norm'] = prijimatelia['meno'].downcase
end

ziadosti.each do
  ziadosti['zadiatel_norm'] = ziadosti['ziadatel']
end

