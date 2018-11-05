require_relative '../errors'
require_relative '../models/operation'

module Labor
	module Permission
		def permission_require(deploy, user_id, operate)
			# 400
			raise Labor::Error::BadRequest, "user_id is required when #{operate} #{deploy.name}" if user_id.nil?

			user = User.find(user_id)
			return if user.superman

			unless deploy&.user_id == user_id
				# 外层拦截，转成 403
				raise Labor::Error::PermissionReject, "User #{user.nickname} doesn't have permission to #{operate} #{deploy.name}"
			end

			# 这里可以记录操作日志
			operation = Operation.create(name: operate)
			operation.send("#{deploy.class.to_s.demodulize.underscore}=", deploy)
			operation.user = user 
			operation.save
		end
	end
end
