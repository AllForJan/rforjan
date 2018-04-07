require 'hippie_csv'
require 'awesome_print'
require_relative 'dbconn'

# path = 'data/crp_projekty_2018-03-26.csv'
# IO.write(path, IO.read(path).encode('UTF-8', invalid: :replace, replace: ''))

$conn = db_connection

BATCH_SIZE = 1000
TABLE_NAME = 'crp_projekty'.freeze

$conn.exec("DELETE from #{TABLE_NAME}")
all_values = []

def insert_batch(all_values)
  placeholders = all_values.each_with_index.map { |batch, idx|
    dollars = 1.upto(batch.size).map { |i| "$#{i + batch.size * idx}" }.join(',')
    "(#{dollars})"
  }.join(', ')
  sql = "INSERT INTO #{TABLE_NAME}
(url, nazov, datum_zverejnenia, datum_zacatia, datum_ukoncenia, prijimatel, ico_prijmatela, miesto_realizacie, poskytovatel, typ_poskytnutej_pomoci, crp_id, vyska_pomoci, vyska_pomoci_num) VALUES #{placeholders}"
  # puts sql
  # puts all_values.flatten
  $conn.exec_params(sql, all_values.flatten)
end

index = 0
CSV.foreach('data/crp_projekty_2018-03-26.csv', { col_sep: ';', quote_char: '"' }) do |row|
  if index == 0
    $header = row
  else
    values = $header.zip(row).map do |field, value|
      case field
        when 'Datum zverejnenia', 'Datum zacatia', 'Datum ukoncenia'
          begin
            Date.parse(value)
          rescue
            nil
          end
        else
          value
      end
    end

    # Add decimal representation of "vyska_pomoci" field
    values << values.last&.gsub(/[^\d,.]/,'')&.to_i

    all_values << values

    if index % BATCH_SIZE == 0
      insert_batch(all_values)
      all_values = []
      ap "Inserted #{index} records"
    end
  end

  index = index + 1
end

insert_batch(all_values)

$conn.exec("SELECT COUNT(*) as c from #{TABLE_NAME}") do |result|
  ap "Total row count #{result.first['c']}"
end



