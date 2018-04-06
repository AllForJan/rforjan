require 'hippie_csv'
require 'awesome_print'
require_relative 'dbconn'

conn = db_connection

BATCH_SIZE = 1000
PREPARED_STATEMENT_NAME = 'insert_apa_ziadosti-o-projektove-podpory_2018-04-03'.freeze

all_values = []
HippieCSV.read('data/apa_ziadosti-o-projektove-podpory_2018-04-03.csv').each_with_index do |row, index|
  if index == 0
    $header = row
  else
    values = $header.zip(row).map do |field, value|
      case field
        when 'Datum RoN/datum zastavenia konania'
        when 'Datum ucinnosti zmluvy'
          begin
            Date.parse(value)
          rescue
            nil
          end
        when 'Schvaleny NFP celkom', 'Vyplateny NFP celkom'
          value.sub(',', '.')
        else
          value
      end
    end

    all_values << values

    if index % BATCH_SIZE == 0
      placeholders = all_values.each_with_index.map { |batch, idx|
        dollars = 1.upto(batch.size).map { |i| "$#{i + batch.size * idx}" }.join(',')
        "(#{dollars})"
      }.join(', ')
      sql = "INSERT INTO  apa_ziadosti_projektove_podpory
(ziadatel, ico, kod_projektu, nazov_projektu, vuc, cislo_vyzvy,
    kod_podopatrenia, status, datum_zastavenia_konania,
    dovod_zastavenie_konania, datum_ucinnosti_zmluvy, schvaleny_nfp_celkom,
    vyplateny_nfp_celkom, pocet_bodov) VALUES #{placeholders}"
      conn.exec_params(sql, all_values.flatten)
      all_values = []

      ap "Inserted #{index} records"
    end
  end
end



