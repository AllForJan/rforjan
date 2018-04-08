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
DB_TABLE = DB[:apa_prijimatelia]
COLUMNS = DB_TABLE.columns - [:id]

path = 'data/apa_prijimatelia_2018-03-15.csv'


puts "Cleaning up old data"

DB_TABLE.truncate(cascade: true)


puts "Ensuring correct encoding"

fixed_encoding_file = Tempfile.new(['csv', '.csv'])
IO.write(fixed_encoding_file.path, IO.read(path).encode('UTF-8', invalid: :replace, replace: ''))
path = fixed_encoding_file.path


puts "Importing"

imported_count = 0

CSV.foreach(path, col_sep: ';', quote_char: '"', headers: true)
  .lazy
  .map { |csv_row|
    csv_row['Suma'] = BigDecimal(csv_row['Suma'])
    csv_row['Rok'] = Integer(csv_row['Rok'])

    meno_normalized = Normalizer.normalize_name(csv_row['Meno'])

    csv_row.fields + [meno_normalized]
  }
  .each_slice(20_000) do |slice|
    DB_TABLE.import(COLUMNS, slice)
    imported_count += slice.size
    puts "Imported #{imported_count} rows"
  end
