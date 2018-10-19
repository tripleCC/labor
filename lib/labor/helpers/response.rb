module Labor
	module Response
		def labor_response(data = {}, options = {}) 
			includes = options[:includes] || []
			errors = options[:errors]
			meta = options[:meta]
			{
				data: data,
				errors: errors,
				meta: meta
			}.reject {|_, v| v.nil? }.to_json(:include => includes)
		end

		def labor_error(error)
			labor_response(nil, {
				errors: Array(error)
				}) 
		end
	end
end
