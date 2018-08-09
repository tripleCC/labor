require_relative './models/pod_deploy'
require_relative './models/main_deploy'

require 'active_record'
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: './my.sqlite3'
  # database: ':memory:'
)
