require 'active_support/core_ext/module/delegation'

module Delayed
  class PerformableMethod
    attr_accessor :object, :method_name, :args

    delegate :method, :to => :object

    def initialize(object, method_name, args)
      fail NoMethodError.new("undefined method `#{method_name}' for #{object.inspect}") unless object.respond_to?(method_name, true)

      if object.respond_to?(:persisted?) && !object.persisted?
        fail ArgumentError.new("job cannot be created for non-persisted record: #{object.inspect}")
      end

      self.object       = object
      self.args         = args
      self.method_name  = method_name.to_sym
    end

    def display_name
      if object.is_a?(Class)
        "#{object}.#{method_name}"
      else
        "#{object.class}##{method_name}"
      end
    end

    def perform
      object.send(method_name, *args) if object
    end

    def method_missing(symbol, *args)
      object.send(symbol, *args)
    end

    def respond_to?(symbol, include_private = false)
      super || object.respond_to?(symbol, include_private)
    end
  end
end
