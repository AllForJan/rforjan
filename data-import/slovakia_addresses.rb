# id, street, number, unit, city, district, region, postcode, hash, location

require 'hippie_csv'
require 'awesome_print'
require_relative 'dbconn'

$conn = db_connection

BATCH_SIZE = 1000
TABLE_NAME = 'slovakia_addresses'.freeze

$conn.exec("DELETE from #{TABLE_NAME}")
all_values = []

def insert_batch(all_values)
  placeholders = all_values.each_with_index.map { |batch, idx|
    dollars = 1.upto(batch.size).map { |i| "$#{i + batch.size * idx}" }.join(',')
    "(#{dollars})"
  }.join(', ')

  sql = "INSERT INTO #{TABLE_NAME}
          (street, number, unit, city, district, region, postcode, hash, location)
        VALUES #{placeholders}"

  # puts sql
  $conn.exec_params(sql, all_values.flatten)
end

HippieCSV.read('data/countrywide.csv').each_with_index do |row, index|
  if index == 0
    $header = row
  else
    # puts row
    # puts $header

    row_hash = $header.zip(row).to_h

    values = [row_hash['STREET'],
              row_hash['NUMBER'],
              row_hash['UNIT'],
              row_hash['CITY'],
              row_hash['DISTRICT'],
              row_hash['REGION'],
              row_hash['POSTCODE'],
              row_hash['HASH'],
              "POINT(#{row_hash['LON']} #{row_hash['LAT']})"]

    all_values << values

    if index % BATCH_SIZE == 0
      insert_batch(all_values)
      all_values = []
      ap "Inserted #{index} records"
    end
  end
end

insert_batch(all_values)

$conn.exec("SELECT COUNT(*) as c from #{TABLE_NAME}") do |result|
  ap "Total row count #{result.first['c']}"
end
