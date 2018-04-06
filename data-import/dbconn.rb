require 'pg'
require 'dotenv'
Dotenv.load

def db_connection
  PG::Connection.open(hostaddr: '138.68.66.142', dbname: 'rforjan', user: 'rforjan', password: ENV['PG_PASS'])
end