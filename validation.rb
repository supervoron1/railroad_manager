# frozen_string_literal: true

module Validation
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    attr_reader :validators

    def validate(attr_name, type, *attributes)
      @validators ||= []
      @validators << { attr_name: attr_name, type: type, attributes: attributes }
    end
  end

  module InstanceMethods
    def validate!
      self.class.validators.each do |validation|
        value = instance_variable_get("@#{validation[:attr_name]}")
        method_name = "validate_#{validation[:type]}"
        send(method_name, value, *validation[:attributes])
      end
    end

    def valid?
      validate!
      true
    rescue StandardError
      false
    end

    private

    def validate_presence(attr_name)
      raise "Значение атрибута #{attr_name} не может быть nil" if attr_name.nil?
      raise "Значение атрибута #{attr_name} не может быть пустой строкой" if attr_name.strip.empty?
    end

    def validate_format(attr_name, format)
      raise "Значение атрибута #{attr_name} не соответствует формату" if attr_name !~ format
    end

    def validate_type(attr_name, type)
      raise "Значение атрибута #{attr_name} не соответствует классу #{type}" unless attr_name.is_a?(type)
    end
  end
end
