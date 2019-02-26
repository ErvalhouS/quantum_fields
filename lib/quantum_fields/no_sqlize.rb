# frozen_string_literal: true

module QuantumFields
  # Module to enable virtual methods in moduls, it creates necessary
  # methods to simulate the behavior that any field can exist, getting
  # or setting it is like a migrated column behaves.
  module NoSqlize
    extend ActiveSupport::Concern
    # Overriding `method_missing` does the magic of assigning an absent field
    # into `.parameters` JSON as a key-value pair, or recovering it's value if
    # exists.
    def method_missing(meth, *args, &block)
      method_name = meth.to_s
      super if method_name.ends_with?('!')
      bad_config! unless can_no_sqlize?
      no_sqlize!(method_name, *args, &block)
    rescue StandardError
      super
    end

    # Used to map which methods can be called in the instance, it is based on
    # the premisse that you can always assign a value to any field and recover
    # only existing fields or the ones that are in the `.parameters` JSON.
    def respond_to_missing?(method_name, include_private = false)
      bad_config! unless can_no_sqlize?
      meth = method_name.to_s
      meth.ends_with?('=') || meth.ends_with?('?') ||
        try(fields_column).try(:[], meth).present? || super
    end

    # Overriding a ActiveRecord method that is used in `.create` and `.update`
    # methods to assign a value into an attribute.
    def _assign_attribute(key, value)
      initialize_fields
      public_send("#{key}=", value) ||
        try(fields_column).try(:except!, key.to_s)
    end

    private

    # Retrieves current model class
    def model
      self.class
    end

    # Retrieves  fields_column configured in current scope
    def fields_column
      model.fields_column
    end

    # Checks for `.parameters` presence and initializes it.
    def initialize_fields
      try("#{fields_column}=", {}) unless try(fields_column).present?
    end

    # The behavior that a noSQL method should have. It either assigns a value into
    # an attribute or retrieves it's value, depending in the method called.
    def no_sqlize!(meth, *args, &_block)
      initialize_fields
      if meth.ends_with?('=')
        assing_to(meth.chomp('='), args.first)
      elsif meth.ends_with?('?')
        read_nosqlized(meth.chomp('?')).present?
      else
        read_nosqlized(meth)
      end
    end

    # Read the value of a `meth` key in :fields_column
    def read_nosqlized(meth)
      try(fields_column).try(:[], meth)
    end

    # Assings a value to a key in :fields_column which allows saving any virtual
    # attribute
    def assing_to(param, value)
      try(fields_column).try(:[]=, param, value)
    end

    # Checks if requirements are met for the feature
    def can_no_sqlize?
      model.column_names.include?(fields_column.to_s) &&
        %i[hstore json jsonb].include?(no_sqlize_column.type)
    end

    # Retrieve which column is being used to sqlize
    def no_sqlize_column
      model.columns.find { |col| col.name == fields_column.to_s }
    end

    # Raises an exception indicating bad configuration of the gem
    def bad_config!
      raise NotImplementedError,
            "#{model.table_name} should have a `#{fields_column}` JSON column"
    end
  end
end
