module Labor
	module Error
		class Base < StandardError; end

		class NotFound < Base; end

		class VersionInvalid < Base; end

		class Oauth < Base; end

		class PermissionReject < Base; end

		class BadRequest < Base; end
	end
end