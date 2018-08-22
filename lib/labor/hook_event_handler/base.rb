require 'gitlab'
require_relative '../logger'

module Labor
	module HookEventHandler
		class Base
			include Labor::Logger
			
			attr_reader :object

			def initialize(hash) 
				@object = Gitlab::ObjectifiedHash.new(hash)
			end
			
			def self.event_kind
				self.name.demodulize.underscore
			end

			def object_attributes
				@object.object_attributes
			end

			def handle
				raise NotImplementedError.new("#{self.class.name}#handle是抽象方法")
			end

			def respond_to_missing?(method, include_private = false)
				object.respond_to?(method) || super
			end

			def method_missing(method, *args, &block)
				super unless object.respond_to?(method)
				object.send(method, *args)
			end
		end
	end
end