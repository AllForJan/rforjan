require 'bigdecimal'
require 'bigdecimal/util'

require 'hippie_csv'
require 'awesome_print'
require_relative 'dbconn'
require_relative '../api/app/models/normalizer'

$conn = db_connection

BATCH_SIZE = 1000
TABLE_NAME = 'apa_prijimatelia'.freeze

$conn.exec("DELETE from #{TABLE_NAME}")
all_values = []

def insert_batch(all_values)
  placeholders = all_values.each_with_index.map { |batch, idx|
    dollars = 1.upto(batch.size).map { |i| "$#{i + batch.size * idx}" }.join(',')
    "(#{dollars})"
  }.join(', ')

  sql = "INSERT INTO #{TABLE_NAME}
          (url, meno, psc, obec, opatrenie, opatrenie_kod, suma, rok, meno_normalized)
        VALUES #{placeholders}"
  $conn.exec_params(sql, all_values.flatten)
end


HippieCSV.read('data/apa_prijimatelia_2018-03-15.csv').each_with_index do |row, index|
  if index == 0
    $header = row
  else
    values = $header.zip(row).map do |field, value|
        case field
          when 'Suma'
            value&.to_d
          when 'Rok'
            value&.to_i
          else value
        end
    end

    values.append(Normalizer.normalize_name(row[1]))

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
