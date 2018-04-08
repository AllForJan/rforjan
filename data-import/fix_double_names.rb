require 'csv'
require 'pg'
require 'sequel'
require 'dotenv'
require_relative '../api/app/models/normalizer'

Dotenv.load

DB = Sequel.connect(adapter: 'postgres', host: '138.68.66.142', database: 'rforjan', user: 'rforjan', password: ENV['PG_PASS'])

sql = <<~SQL
  SELECT id, meno
  FROM apa_prijimatelia
SQL

# Retazce cislic miesto mena: pod nejakú hranicu (myslím 1000 Eur) sú prijímatelia anonymizovaní týmto spůsobom
rows = DB.fetch(sql).all

rows.each do |row|
  meno = row[:meno]

  if meno.length % 2 == 0
    half_length = meno.length / 2
    first_half = meno[0...half_length]
    second_half = meno[half_length..-1]

    if first_half == second_half
      DB[:apa_prijimatelia].where(id: row[:id]).update(meno: first_half, meno_normalized: Normalizer.normalize_name(first_half))
    end
  end
end
