require_relative 'dbconn'
require 'I18n'

I18n.config.available_locales = :en

def normalize_name(name)
  I18n.transliterate(name).downcase.gsub(/[^\w]/,' ').split.compact.sort.uniq.join(' ')
end

$conn = db_connection

prijimatelia = $conn.exec('select * from apa_prijimatelia limit 10000').to_a
ziadosti = $conn.exec('select * from apa_ziadosti_o_priame_podpory_diely limit 10000').to_a


prijimatelia.each do |prijimatel|
  prijimatel['meno_norm'] = normalize_name(prijimatel['meno'])
end

ziadosti.each do |ziadost|
  ziadost['ziadatel_norm'] = normalize_name(ziadost['ziadatel'])
end

master = []

not_found = 0
duplicate = 0

ziadosti.each do |ziadost|
  new_row = ziadost

  prijimatel = prijimatelia.select { |p| p['meno_norm'] == ziadost['ziadatel_norm'] }
  if prijimatel.size > 1
    puts "Duplicate: #{ziadost.inspect}"
  elsif prijimatel.size == 1
    new_row.merge(prijimatel.first)
  end

  master.append(new_row)
end

puts "Rows #{master.length}"


