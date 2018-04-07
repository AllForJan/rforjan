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

paths = ['data/finstat.csv', 'data/prijimatelia_bez_ico_finstat.csv']


puts "Cleaning up old data"

DB_TABLE.truncate(cascade: true)


imported_count = 0

paths.each do |path|
  puts "Importing from #{path}"

  CSV.foreach(path, col_sep: ';', quote_char: '"', headers: true)
    .lazy
    .select { |csv_row| csv_row['Nazov'].present? }
    .map { |csv_row|
      csv_row['Dlhy'] = csv_row['Dlhy'] == 'áno'

      years = 2017.downto(2009)
      decimal_columns = years.flat_map { |y| ["#{y} Trzby", "#{y} Trzby+vynosy", "#{y} Zisk", "#{y} Aktiva"] }
      decimal_columns.each do |col|
        csv_row[col] = BigDecimal(csv_row[col]) if csv_row[col]
      end

      csv_row.values_at(
        'Ico', 'Nazov', 'Hlavna cinnost', 'SK Nace', 'Dátum vzniku', 'Dátum zániku',
        'Dlhy', 'Zamestnanci', 'Zamestnanci - presny pocet',
        'Adresa', 'Mesto', 'Okres', 'Kraj', 'Štatutári',
        '2017 Trzby', '2017 Trzby+vynosy', '2017 Zisk', '2017 Aktiva', '2017 Zamestnanci',
        '2016 Trzby', '2016 Trzby+vynosy', '2016 Zisk', '2016 Aktiva', '2016 Zamestnanci',
        '2015 Trzby', '2015 Trzby+vynosy', '2015 Zisk', '2015 Aktiva', '2015 Zamestnanci',
        '2014 Trzby', '2014 Trzby+vynosy', '2014 Zisk', '2014 Aktiva', '2014 Zamestnanci',
        '2013 Trzby', '2013 Trzby+vynosy', '2013 Zisk', '2013 Aktiva', '2013 Zamestnanci',
        '2012 Trzby', '2012 Trzby+vynosy', '2012 Zisk', '2012 Aktiva', '2012 Zamestnanci',
        '2011 Trzby', '2011 Trzby+vynosy', '2011 Zisk', '2011 Aktiva', '2011 Zamestnanci',
        '2010 Trzby', '2010 Trzby+vynosy', '2010 Zisk', '2010 Aktiva', '2010 Zamestnanci',
        '2009 Trzby', '2009 Trzby+vynosy', '2009 Zisk', '2009 Aktiva', '2009 Zamestnanci'
      )
    }
    .each_slice(20_000) do |slice|
      DB_TABLE.import(COLUMNS, slice)
      imported_count += slice.size
      puts "Imported #{imported_count} rows"
    end
end
