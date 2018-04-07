require 'csv'
require 'pg'
require 'sequel'
require 'dotenv'
require 'tempfile'
require 'bigdecimal'
require 'active_support/core_ext/object/blank'

Dotenv.load

DB = Sequel.connect(adapter: 'postgres', host: '138.68.66.142', database: 'rforjan', user: 'rforjan', password: ENV['PG_PASS'])
DB_TABLE = DB[:apa_ziadosti_o_priame_podpory]
COLUMNS = DB_TABLE.columns - [:id]

path = 'data/apa_ziadosti_o_priame_podpory_2018-03-20.csv'


puts "Cleaning up old data"

DB_TABLE.truncate


puts "Ensuring correct encoding"

fixed_encoding_file = Tempfile.new(['csv', '.csv'])
IO.write(fixed_encoding_file.path, IO.read(path).encode('UTF-8', invalid: :replace, replace: ''))
path = fixed_encoding_file.path


puts "Importing"

imported_count = 0

CSV.foreach(path, col_sep: ';', quote_char: '"')
  .lazy
  .drop(1)
  .map { |csv_line|
    ico = csv_line[2]&.rjust(8, '0')&.slice(-8..-1)

    rok = Integer(csv_line[3])

    normalized = csv_line.map(&:presence)
    normalized[2] = ico
    normalized[3] = rok
    normalized
  }
  .each_slice(20_000) do |slice|
    DB_TABLE.import(COLUMNS, slice)
    imported_count += slice.size
    puts "Imported #{imported_count} rows"
  end
