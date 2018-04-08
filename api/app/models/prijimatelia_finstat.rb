class PrijimateliaFinstat < ApplicationRecord
  self.table_name = 'prijimatelia_finstat'
  belongs_to :prijimatelia, class_name: 'ApaPrijimatelia'
  belongs_to :finstat, class_name: 'Finstat'
end
