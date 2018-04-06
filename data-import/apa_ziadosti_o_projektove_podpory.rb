require 'pg'
require 'hippie_csv'

HippieCSV.stream('data/apa_ziadosti-o-projektove-podpory_2018-04-03.csv').each_with_index do |index, row|
  if index == 0
    $header = row
  else
    values = $header.zip(row).map do |field, value|
        case field
        when 'Datum RoN/datum zastavenia konania'
        when 'Datum ucinnosti zmluvy'
            Date.parse(value)
        else value 
        end

    end.map { |s| "'#{s}'" }.join(', ')

    conn.execute(<<~SQL)
        INSERT INTO  apa_ziadosti_projektove_podpory (ziadatel, ico, kod_projektu, nazov_projektu, vuc, cislo_vyzvy, kod_podopatrenia, status, datum_zastavenia_konania, dovod_zastavenie_konania, datum_ucinnosti_zmluvy, schvaleny_nfp_celkom, vyplateny_nfp_celkom, pocet_bodov) VALUES (#{values}.join(', '))})
    SQL
  end
end