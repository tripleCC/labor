module Labor
	module Error
		class Base < StandardError; end

		class NotFound < Base; end

		class VersionInvalid < Base; end

		class Oauth < Base; end
	end
end