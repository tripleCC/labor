module Labor
	module RetryRescue
		def retry_rescue(error_cls, times = 5, sleep_duration = 0.15, &block)
			tries ||= times
			yield tries if block_given?
		rescue error_cls => error
			tries -= 1
			if tries.zero? 
				raise error
			else
				sleep(sleep_duration)
				retry
			end
		end
	end
end