module Labor
	module Async
		def async_each(mappable, &block)
			mappable.map do |item|
				thread = Thread.new do 
					block.call(item)
				end
				thread
			end.each(&:join)
		end
	end
end