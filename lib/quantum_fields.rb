# frozen_string_literal: true

require 'active_support/concern'
require 'quantum_fields/railtie'
require 'quantum_fields/validation_injector'
require 'quantum_fields/no_sqlize'
require 'quantum_fields/active_record_patch'

# A module to abstract a noSQL aproach into SQL records, using a `parameters`
# JSON column.
module QuantumFields
  extend ActiveSupport::Concern
  # This module contains the methods called within the Model to initialize
  # and to manage how the other methods should behave on the given context.
  module ClassMethods
    def no_sqlize(args = {})
      class_eval <<-RUBY, __FILE__, __LINE__+1
        def self.fields_column
          :#{args[:fields_column] || :parameters}
        end
        def self.rules_column
          :#{args[:rules_column] || :parameters_rules}
        end
      RUBY
      include QuantumFields::NoSqlize
      include QuantumFields::ValidationInjector
    end
  end
end

ActiveRecord::Base.send(:include, QuantumFields)