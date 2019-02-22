# frozen_string_literal: true

module QuantumFields
  module Support
    # Abstracts PostgreSQL support for quantum_fields operations
    module Postgresql
      class << self
        # Returns an Arel node in the context of given field and JSON key,
        # which in this context constructs as "'my_json_field'->>'my_key'"
        def field_node(field, key)
          Arel::Nodes::InfixOperation.new('->>',
                                          field,
                                          Arel::Nodes.build_quoted(key))
        end
      end
    end
  end
end
