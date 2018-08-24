module Labor
	module Response
		def labor_response(data = {}, includes = [], errors = nil, meta = nil) 
			{
				data: data,
				errors: errors,
				meta: meta
			}.reject {|_, v| v.nil? }.to_json(:include => includes)
		end

		def labor_error(error)
			labor_response(nil, [], Array(error)) 
		end
	end
end
