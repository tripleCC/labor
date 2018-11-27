require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require_relative './lib/labor/config'

options = {
  port: Labor.config.port,
  host: Labor.config.host,
  deploy_host: Labor.config.deploy_host
}

pid_file = File.expand_path("#{__FILE__}/../labor.pid")
redis_pid_file = File.expand_path("#{__FILE__}/../sidekiq.pid")
# sidekiq_log_file = Labor.config.sidekiq_log_file

# 运行 sidekiq 前，需要手动启动 redis
# redis 相关
# brew install redis
# brew services start redis （后台）
# redis-server /usr/local/etc/redis.conf （前台）
# redis-cli shutdown

# 如果在 mac 中遇到 sidekiq -d 执行失败，log 显示 [__NSPlaceholderDictionary initialize] may have been in progress in another thread when fork() was called
# 则先执行以下语句
# export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
# https://stackoverflow.com/questions/46591470/unicorn-with-ruby-2-4-1-causing-weird-crash

# 有 puma 的情况下，rack 默认使用 Puma 

task :run do 
	# Q: sidekiq 会影响 websocket 服务，不知道为什么
	# A: sidekiq -r 指定 worker 文件，不要乱指定，否则会 require 两次，创建两次类
	# 相当于两个不同的服务，这样 socket 在命令行第一句创建后，命令行第二句就不会创建了，导致共享类错误
	# 起 sidekiq 相当于跑另外一个服务，代码要重新执行一遍，无法共享 ws，放弃了
	# 要用的话，需要起一个 websocket server ，然后用 redis 和 web server 通信，sidekiq 直接操作 redis
	# system "bundle exec sidekiq -r ./lib/labor/workers.rb -P #{redis_pid_file} -L #{sidekiq_log_file} -q default -d"
	system "bundle exec rackup -P #{pid_file} -p #{options[:port]} -o #{options[:host]}"
end

task :deploy do 
	# 后台运行
	#  -D 
	# system "bundle exec sidekiq -r ./lib/labor/workers.rb -P #{redis_pid_file} -L #{sidekiq_log_file} -q default -d -e production"  
	system "bundle exec rackup -P #{pid_file} -p #{options[:port]} -o #{options[:deploy_host]} -E production"
	puts "Deployed Labor web server"
end

task :stop do 
	[pid_file, redis_pid_file].select { |file| File.exist?(file) }.each do |pid_file|
    pid = File.read(pid_file)
    begin 
    	`kill -9 #{pid.to_i}`
    	# Process.kill('INT', pid.to_i)
	    puts "Stopped by pid #{pid} and file #{pid_file}"
    rescue => error 
    	puts "#{error.message} #{pid_file}"
    ensure 
    	File.delete(pid_file)
    end
	end
	# system "sidekiqctl stop #{redis_pid_file}"
	# File.delete(redis_pid_file) if File.exist?(redis_pid_file)
end

task :restart do 
	system 'rake stop'
	system 'rake run'
end


# RACK_ENV=production xxxx

# bundle exec ruby test.rb -e production -p 8080

# rake db:create              # Creates the database from DATABASE_URL or config/database.yml for the current RACK_ENV (use db:create:all to create all databases in the config)....
# rake db:create_migration    # Create a migration (parameters: NAME, VERSION)
# rake db:drop                # Drops the database from DATABASE_URL or config/database.yml for the current RACK_ENV (use db:drop:all to drop all databases in the config). Witho...
# rake db:fixtures:load       # Load fixtures into the current environment's database
# rake db:migrate             # Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)
# rake db:migrate:status      # Display status of migrations
# rake db:rollback            # Rolls the schema back to the previous version (specify steps w/ STEP=n)
# rake db:schema:cache:clear  # Clear a db/schema_cache.dump file
# rake db:schema:cache:dump   # Create a db/schema_cache.dump file
# rake db:schema:dump         # Create a db/schema.rb file that is portable against any DB supported by AR
# rake db:schema:load         # Load a schema.rb file into the database
# rake db:seed                # Load the seed data from db/seeds.rb
# rake db:setup               # Create the database, load the schema, and initialize with the seed data (use db:reset to also drop the database first)
# rake db:structure:dump      # Dump the database structure to db/structure.sql
# rake db:structure:load      # Recreate the databases from the structure.sql file
# rake db:version             # Retrieves the current schema version number