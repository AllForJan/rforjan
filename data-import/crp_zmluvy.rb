require 'hippie_csv'
require 'awesome_print'
require_relative 'dbconn'

path = 'data/crp_zmluvy_2018-03-26.csv'
IO.write(path, IO.read(path).encode('UTF-8', invalid: :replace, replace: ''))

$conn = db_connection

BATCH_SIZE = 1000
TABLE_NAME = 'crp_zmluvy'.freeze

$conn.exec("DELETE from #{TABLE_NAME}")
all_values = []



def insert_batch(all_values)
  placeholders = all_values.each_with_index.map { |batch, idx|
    dollars = 1.upto(batch.size).map { |i| "$#{i + batch.size * idx}" }.join(',')
    "(#{dollars})"
  }.join(', ')
  sql = "INSERT INTO #{TABLE_NAME}

(url, crp_id, nazov , obstaravatel_nazov, obstaravatel_ic, dodavatel_nazov, dodavatel_ico, dodavatel_adresa, nazov_zmluvy, datum_uzavretia, datum_ucinnosti, poznamka_k_ucinnosti, datum_platnosti, suma_s_dph, poznamka, prilohy_url, prilohy_nazvy, prilohy_subory, interne_id, datum_zverejnenia, stav) VALUES #{placeholders}"
  # puts sql
  # puts all_values.flatten
  $conn.exec_params(sql, all_values.flatten)
end

index = 0
CSV.foreach('data/crp_zmluvy_2018-03-26.csv', { col_sep: ';', quote_char: '"' }) do |row|
  if index == 0
    $header = row
  else
    values = $header.zip(row).map do |field, value|
      case field
        when 'Datum uzavretia', 'Datum ucinnosti', 'Datum platnosti', 'Datum zverejnenia'
          begin
            Date.parse(value)
          rescue
            nil
          end
        else
          value
      end
    end

    # if values.length != 21
    #   puts values.inspect
    #   puts values.length
    #   raise StandardError, ':('
    # end

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



