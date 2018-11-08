module Labor
	module Request
		def body_params
			request.body.rewind
			body = request.body.read
			params = JSON.parse(body) unless body.to_s.empty?
			params || {}
		end
	end
end
