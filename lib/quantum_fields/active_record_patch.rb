# frozen_string_literal: true

ActiveRecord::PredicateBuilder.class_eval do
  # Builds an binded Arel operation, injecting json operator if necessary
  def build(attribute, value)
    if table.type(attribute.name).force_equality?(value)
      bind = build_bind_attribute(attribute.name, value)
      attribute.eq(bind)
    elsif table.send('klass').respond_to?(:fields_column) && !table.send('klass').column_names.include?(attribute.name)
      op = QuantumFields::Support.field_node(table.send('klass').arel_table[table.send('klass').fields_column], attribute.name)
      attribute.name = table.send('klass').fields_column.to_s
      bind = build_bind_attribute(op, value)
      op.eq(bind)
    else
      handler_for(value).call(attribute, value)
    end
  end
end
ActiveRecord::Relation.class_eval do
  # Returns an Arel::Node that is used to query a field.
  # In case that attribute is a column or if current model
  # hasn't initialized 'no_sqlize' keeps Rails' behavior.
  def arel_attribute(name)
    if klass.column_names.include?(name.to_s) || !klass.respond_to?(:fields_column)
      klass.arel_attribute(name, table)
    else
      QuantumFields::Support.field_node klass.arel_table[klass.fields_column],
                                        name
    end
  end
end

ActiveModel::AttributeMethods::ClassMethods.module_eval do
  # Is +new_name+ an alias or a quantum field?
  def attribute_alias?(new_name)
    attribute_aliases.key?(new_name.to_s) ||
      (!['all', 'star', ' ', '*'].include?(new_name.to_s) &&
        respond_to?(:fields_column) &&
        !column_names.include?(new_name.to_s))
  end
  # Returns the original name or quantum field for the alias +name+
  def attribute_alias(name)
    if column_names.include?(name.to_s) || !respond_to?(:fields_column)
      attribute_aliases[name.to_s]
    else
      name
    end
  end
end