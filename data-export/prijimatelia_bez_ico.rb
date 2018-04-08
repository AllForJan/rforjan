require 'csv'
require 'pg'
require 'sequel'
require 'dotenv'

Dotenv.load

DB = Sequel.connect(adapter: 'postgres', host: '138.68.66.142', database: 'rforjan', user: 'rforjan', password: ENV['PG_PASS'])

sql = <<~SQL
  SELECT DISTINCT meno, psc, obec
  FROM apa_prijimatelia p 
  LEFT JOIN apa_ziadosti_o_priame_podpory z ON z.ziadatel = p.meno 
  WHERE z.ico IS NULL
SQL

# Retazce cislic miesto mena: pod nejakú hranicu (myslím 1000 Eur) sú prijímatelia anonymizovaní týmto spůsobom
rows = DB.fetch(sql).all.uniq { |row| row[:meno] }.select { |row| /[[:alpha:]]/ =~ row[:meno] }

CSV.open('data/prijimatelia_bez_ico.csv', 'w') do |csv|
  csv << %i[meno psc obec]

  rows.each do |row|
    csv << row.values
  end
end
