require 'csv'
require 'pg'
require 'sequel'
require 'dotenv'
require 'tempfile'
require 'bigdecimal'
require 'active_support/core_ext/object/blank'

Dotenv.load

DB = Sequel.connect(adapter: 'postgres', host: '138.68.66.142', database: 'rforjan', user: 'rforjan', password: ENV['PG_PASS'])
DB_TABLE = DB[:finstat]
COLUMNS = DB_TABLE.columns - [:id]

path = 'data/finstat.csv'


puts "Cleaning up old data"

DB_TABLE.truncate


puts "Importing"

imported_count = 0

CSV.foreach(path, col_sep: ';', quote_char: '"')
  .lazy
  .drop(1)
  .select { |csv_line| csv_line[1].present? }
  .map { |csv_line|
    normalized = csv_line.map(&:presence)

    dlhy_col_idx = COLUMNS.index(:dlhy)
    normalized[dlhy_col_idx] = csv_line[dlhy_col_idx] == 'áno'

    years = 2017.downto(2009)
    decimal_columns = years.flat_map { |y| [:"trzby_#{y}", :"trzby_vynosy_#{y}", :"zisk_#{y}", :"aktiva_#{y}"] }

    decimal_columns.each do |column_name|
      col_idx = COLUMNS.index(column_name)
      normalized[col_idx] = BigDecimal(csv_line[col_idx]) if csv_line[col_idx]
    end

    normalized
  }
  .each_slice(20_000) do |slice|
    DB_TABLE.import(COLUMNS, slice)
    imported_count += slice.size
    puts "Imported #{imported_count} rows"
  end
