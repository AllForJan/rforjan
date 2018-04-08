require 'csv'
require 'pg'
require 'sequel'
require 'dotenv'
require 'tempfile'
require 'bigdecimal'
require 'active_support/core_ext/object/blank'
require_relative '../api/app/models/normalizer'

Dotenv.load

DB = Sequel.connect(adapter: 'postgres', host: '138.68.66.142', database: 'rforjan', user: 'rforjan', password: ENV['PG_PASS'])

path = 'data/prijimatelia_bez_ico_finstat.csv'


puts "Cleaning up prijimatelia_finstat"

DB[:prijimatelia_finstat].truncate(cascade: true)


imported_count = 0

puts "Importing prijimatelia_finstat rows"

CSV.foreach(path, col_sep: ';', quote_char: '"', headers: true)
  .lazy
  .select { |csv_row| csv_row['Ico'].present? }
  .map { |csv_row|
    prijimatelia_ids = DB[:apa_prijimatelia].where(meno: csv_row['Origin_Name'], psc: csv_row['Origin_PSC'], obec: csv_row['Origin_Mesto']).map(:id)
    finstat_ids = DB[:finstat].where(ico: csv_row['Ico']).map(:id)
    prijimatelia_ids.product(finstat_ids)
  }
  .each do |slice|
    DB[:prijimatelia_finstat].import([:prijimatelia_id, :finstat_id], slice)
    imported_count += slice.size
    puts "Imported #{imported_count} rows"
  end
