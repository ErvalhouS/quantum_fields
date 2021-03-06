# frozen_string_literal: true

require 'active_record'
require 'rails/railtie'
require 'active_support/concern'
require 'quantum_fields/active_record_patch'
require 'quantum_fields/no_sqlize'
require 'quantum_fields/railtie'
require 'quantum_fields/support'
require 'quantum_fields/validation_injector'

# A module to abstract a noSQL aproach into SQL records, using a `parameters`
# JSON column.
module QuantumFields
  extend ActiveSupport::Concern
  # This module contains the methods called within the Model to initialize
  # and to manage how the other methods should behave on the given context.
  module ClassMethods
    # Method called in the model context to initialize behavior and pass
    # configuration options into quantum_fields. You can use a custom column
    # for your fields and a custom column for your injected validation rules.
    # Initializing the gem behavior on default 'quantum_fields' and
    # 'quantum_rules' columns:
    # => no_sqlize
    # Initializing the gem behavior on default 'quantum_rules' column and a
    # custom fields_column 'my_json_field'
    # => no_sqlize fields_column: :my_json_field
    # Initializing the gem behavior on default 'quantum_fields' column and a
    # custom rules_column 'my_json_field', affecting from where to pull
    # injected validations:
    # => no_sqlize rules_column: :my_json_field
    def no_sqlize(args = {})
      class_eval <<-RUBY, __FILE__, __LINE__+1
        def self.fields_column
          :#{args[:fields_column] || :quantum_fields}
        end
        def self.rules_column
          :#{args[:rules_column] || :quantum_rules}
        end
        def as_json(*args)
          super.except(self.class.fields_column.to_s, self.class.rules_column.to_s).tap do |hash|
            self.try(:quantum_fields)&.each do |key, value|
              hash[key] = value
            end
          end
        end
      RUBY
      include QuantumFields::NoSqlize
      include QuantumFields::ValidationInjector
    end
  end
end

ActiveRecord::Base.send(:include, QuantumFields)
