require 'concurrent'

module Labor
	module ThreadPool
		include Concurrent

		def self.thread_pool
			@thread_pool ||= Concurrent::CachedThreadPool.new  
		end 

		def thread_pool
			ThreadPool::thread_pool
		end
	end
end