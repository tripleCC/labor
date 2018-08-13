require 'state_machines-activerecord'
require 'gitlab'
require_relative './logger'

module Labor
	module HookEventHandler
		include Labor::Logger

		class << self 
			def event_kinds
				constants.map { |c| const_get(c) }.map(&:event_kind) - ['base']
			end

			def handler(event_name, hash = {}) 
				handler_cls = const_get(event_name.camelize)
				handler_cls.new(hash) if handler_cls
			end
		end


		class Base
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