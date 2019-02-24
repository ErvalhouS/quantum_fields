# frozen_string_literal: true

require 'quantum_fields/support/postgresql'
require 'quantum_fields/support/mysql2'
require 'quantum_fields/support/sqlite3'

module QuantumFields
  # Module to add support to different database operation
  module Support
    class << self
      # Redirects call to current database context support module
      def field_node(field, key)
        ('QuantumFields::Support::' +
          ActiveRecord::Base.connection
                            .instance_values['config'][:adapter]
                            .classify).constantize.field_node(field, key)
      end
    end
  end
end