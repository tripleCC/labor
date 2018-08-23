module Labor
	module Response
		def labor_response(data = {}, errors = nil, meta = nil) 
			{
				data: data,
				errors: errors,
				meta: meta
			}.to_json
		end
	end
end


		# {
# 	data: [],
# 	errors: [],
# 	meta: {}
# }
