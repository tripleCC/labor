module Labor
	module Error
		class Base < StandardError; end

		class NotFound < Base; end

		class VersionInvalid < Base; end
	end
end