module Labor
	module Response
		def body_params(request) 
			request.body.rewind
			body = request.body.read
			params = JSON.parse(body) unless body.to_s.empty?
			params || {}
		end

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
