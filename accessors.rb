# frozen_string_literal: true

module Accessors
  def attr_accessor_with_history(*names)
    names.each do |name|
      var_name = "@#{name}".to_sym
      name_history = "@#{name}_history".to_sym
      method_name_history = "#{name}_history".to_sym

      define_method(name) { instance_variable_get(var_name) }
      define_method(method_name_history) { instance_variable_get(name_history) }
      define_method("#{name}=") do |value|
        if instance_variable_get(name_history).nil?
          instance_variable_set(name_history, [])
        else
          instance_variable_get(name_history) << instance_variable_get(var_name)
        end
        instance_variable_set(var_name, value)
      end
    end
  end

  def strong_attr_accessor(name, attr_class)
    var_name = "@#{name}".to_sym
    define_method(name) { instance_variable_get(var_name) }
    define_method("#{name}=") do |value|
      raise "Type Error!!!" unless value.is_a?(attr_class)

      instance_variable_set(var_name, value)
    end
  end
end

class Test
  extend Accessors

  attr_accessor_with_history :foo, :bar
end
