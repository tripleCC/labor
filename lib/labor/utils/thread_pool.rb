require 'concurrent'

module Labor
	module ThreadPool
		include Concurrent

		def self.cache_thread_pool
			@cache_thread_pool ||= Concurrent::CachedThreadPool.new  
		end 

		def cache_thread_pool
			ThreadPool::cache_thread_pool
		end
	end
end