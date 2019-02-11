# frozen_string_literal: true

module QuantumFields
  # This module injects a behavior on no_sqlized models that enables backend
  # validations on virtual fields based on rules passed by the instance
  module ValidationInjector
    extend ActiveSupport::Concern
    included do
      before_validation :map_injected_validations
      def map_injected_validations
        send(self.class.rules_column).try(:deep_symbolize_keys)&.each do |field, rules|
          validations = rules[:validates]
          inject_validations(field, validations) if validations.present?
        end
      end

      def inject_validations(field, validations)
        validations.each do |method, value|
          singleton_class.validates field, method => value
        end
      end
    end
  end
end