# frozen_string_literal: true

module QuantumFields
  class NoSqlizedFieldsColumnMissing < RuntimeError
    def initialize(msg="Missing a JSON field to build QuantumFields")
      super
    end
  end
end