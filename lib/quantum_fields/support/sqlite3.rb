# frozen_string_literal: true

module QuantumFields
  module Support
    # Abstracts SQLite support for quantum_fields operations
    module Sqlite3
      class << self
        # Returns an Arel node in the context of given field and JSON key,
        # which in this context constructs as "json_extract("my_models"."my_json_field", '$.key')"
        def field_node(field, key)
          Arel::Nodes::NamedFunction.new('json_extract',
                                         [field,
                                          Arel::Nodes.build_quoted("$.#{key}")])
        end
      end
    end
  end
end
