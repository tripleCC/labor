require_relative '../errors'
require_relative '../models/operation'

module Labor
	module Permission
		def auth_user_id
			auth = Rack::Auth::Basic::Request.new(request.env)
	    user_id = auth.credentials.last if auth.provided? && auth.basic?
	    if user_id.nil?
				raise Labor::Error::Unauthorized, "Not authorized, user_id is required" 
			end
			user_id.to_i
		end

		def superman_require
			user_id = auth_user_id
			user = User.find(user_id)

			unless user.superman
				raise Labor::Error::PermissionReject, "User #{user.nickname} doesn't have permission, only superman is allowed"
			end
		end

		def permission_require(deploy, operate)
	    user_id = auth_user_id

			user = User.find(user_id)

			unless user.superman || 
				deploy.user_id == user_id || 
				deploy.try(:main_deploy)&.user_id == user_id
				# 外层拦截，转成 403
				raise Labor::Error::PermissionReject, "User #{user.nickname} doesn't have permission to operate #{deploy.name} with operation #{operate}"
			end

			# 这里可以记录操作日志
			operation = Operation.create(name: operate)
			operation.deploy_name = deploy.try(:name)
			operation.deploy_type = deploy.class.to_s.demodulize.underscore.split('_').first
			# operation.send("#{deploy.class.to_s.demodulize.underscore}=", deploy)
			operation.user = user 
			operation.save
		end
	end
end
