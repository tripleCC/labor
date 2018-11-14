require 'sinatra/base'

module Labor
	module CleanOptionsRoute
		[:get, :patch, :put, :post, :delete].each do |method|
  		define_method("clean_options_#{method}") do |path, opts = {}, &block|
  			options(path, opts) do end 
  			send(method, path, opts, &block)
  		end
  		# Sinatra::Delegator.delegate method
  	end
	end

	::Sinatra.register CleanOptionsRoute
end
