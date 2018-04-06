require 'pg'
require 'dotenv/load'
require 'awesome_print'

def db_connection
  PG::Connection.open(hostaddr: '138.68.66.142', dbname: 'rforjan', user: 'rforjan', password: ENV['PG_PASS'])
end