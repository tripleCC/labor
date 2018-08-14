require_relative './models/pod_deploy'
require_relative './models/main_deploy'
require 'active_record'

# QLite3::BusyException 错误
# https://rails.lighthouseapp.com/projects/8994/tickets/5941-sqlite3busyexceptions-are-raised-immediately-in-some-cases-despite-setting-sqlite3_busy_timeout
# module SqliteTransactionFix
#   def begin_db_transaction
#     log('begin immediate transaction', nil) { @connection.transaction(:immediate) }
#   end
# end

# module ActiveRecord
#   module ConnectionAdapters
#     class SQLiteAdapter < AbstractAdapter
#       prepend SqliteTransactionFix
#     end
#   end
# end

# ActiveRecord::Base.establish_connection
# (
#   adapter: 'sqlite3',
#   database: './my.sqlite3',
#   pool: 50,
#   timeout: 1000
#   # database: ':memory:'
# )
# ActiveRecord::Base.connection.execute("BEGIN TRANSACTION; END;")