require 'hippie_csv'
require 'awesome_print'
require_relative 'dbconn'

$conn = db_connection

BATCH_SIZE = 1000
TABLE_NAME = 'apa_ziadosti_o_priame_podpory'.freeze

$conn.exec("DELETE from #{TABLE_NAME}")
all_values = []

def insert_batch(all_values)
  placeholders = all_values.each_with_index.map { |batch, idx|
    dollars = 1.upto(batch.size).map { |i| "$#{i + batch.size * idx}" }.join(',')
    "(#{dollars})"
  }.join(', ')
  sql = "INSERT INTO #{TABLE_NAME}
(url, ziadatel, ico, rok, ziadosti) VALUES #{placeholders}"
  # puts sql
  # puts all_values.flatten
  $conn.exec_params(sql, all_values.flatten)
end

HippieCSV.read('data/apa_ziadosti_o_priame_podpory_2018-03-20.csv').each_with_index do |row, index|
  if index == 0
    $header = row
  else
    values = $header.zip(row).map do |field, value|
      case field
        when 'Rok'
          value&.to_i
        else
          value
      end
    end

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



