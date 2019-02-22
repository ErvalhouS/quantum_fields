require 'spec_helper'
require 'quantum_fields'

require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :my_models, force: true do |t|
    t.json :my_json_field
  end
end

class MyModel < ActiveRecord::Base
  no_sqlize fields_column: :my_json_field
end

RSpec.describe QuantumFields do
  describe ActiveRecord::Base do
    it { expect(described_class).to respond_to(:no_sqlize) }

    describe 'basic adapter json field capability' do
      let(:my_instance) { MyModel.create(my_json_field: { a_column_that_does_not_exists: 'I do exist'}) }

      it 'persist a property in a json field' do
        expect(my_instance.my_json_field['a_column_that_does_not_exists']).to eq 'I do exist'
      end
    end

    describe 'virtualization of json keys and values as attributes on queries' do
      let(:my_instance) { MyModel.create(god: 'Here I am') }
      let(:third) { MyModel.create(lero: 3, orderable: 'true') }
      let(:first) { MyModel.create(lero: 1, orderable: 'true') }
      let(:second) { MyModel.create(lero: 2, orderable: 'true') }

      it 'persist a property and it can be accessible as an attribute' do
        expect(my_instance.god).to eq 'Here I am'
      end

      it 'is queryable as a common attribute' do
        expect(MyModel.where(god: 'Here I am')).to include my_instance
      end

      it 'is orderable as a common attribute' do
        expect(MyModel.order(:lero).where(orderable: 'true')).to eq [first, second, third]
      end
    end
  end
end
