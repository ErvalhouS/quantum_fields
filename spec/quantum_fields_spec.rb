require 'spec_helper'
require 'quantum_fields'

require "logger"

configs = YAML.load_file('spec/database.yml')
ActiveRecord::Base.configurations = configs

db_name = ENV['QUANTUM_FIELDS_DB_ADAPTER'] || "sqlite"
ActiveRecord::Base.establish_connection(db_name.to_sym)
ActiveRecord::Base.default_timezone = :utc

ActiveRecord::Base.logger = Logger.new(STDOUT)

puts "==>"
puts "==> Running specs against " \
     "#{ActiveRecord::Base.connection_config[:adapter]} adapter"
puts "==>"

ActiveRecord::Schema.define do
  create_table :my_models, force: true do |t|
    t.json :my_json_field
  end
  create_table :another_models, force: true do |t|
  end
  create_table :virgin_models, force: true do |t|
  end
end

class MyModel < ActiveRecord::Base
  no_sqlize fields_column: :my_json_field
end

class AnotherModel < ActiveRecord::Base
  no_sqlize fields_column: :my_json_field
end

class VirginModel < ActiveRecord::Base
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

      it 'you can check existance of "non-existant" fields' do
        expect(my_instance.god?).to eq true
        expect(my_instance.devil?).to eq false
      end

      it 'is orderable as a common attribute' do
        expect(MyModel.order(:lero).where(orderable: 'true')).to eq [first, second, third]
      end
    end

    describe 'virtualization of validation based on quantum_rules' do
      let(:my_instance) do
        MyModel.new(quantum_rules: {
                      god: { validates: { presence: true } },
                      tweet: { validates: { length: { maximum: 144 } } }
                    })
      end

      it 'rejects a record based on quantum_rules injected presence validation' do
        expect { my_instance.save! }.to raise_error("Validation failed: God can't be blank")
      end

      it 'saves normally when injected presence validation is met' do
        my_instance.god = 'I exist.'
        expect { my_instance.save! }.not_to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'rejects a record based on quantum_rules injected length validation' do
        my_instance.god = 'I exist.'
        my_instance.tweet = 'An overly long tweet :) - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris porttitor, ipsum a vehicula rutrum, odio libero tristique lectus, a dapibus sed.'
        expect { my_instance.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'saves normally when injected length validation is met' do
        my_instance.god = 'I exist.'
        my_instance.tweet = 'This is fine.'
        expect { my_instance.save! }.not_to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe 'edge case treatment' do
      let(:my_instance) { MyModel.create(god: 'Here I am') }
      let(:virgin) { VirginModel.create }
      it "doesn't affect functionality of non-sqlized models" do
        expect { VirginModel.create(god: 'Here I am') }.to raise_error(NoMethodError)
        expect(VirginModel.where(id: virgin.id)).to eq [virgin]
        expect(VirginModel.find(virgin.id)).to eq virgin
      end
      it 'raises a NotImplementedError when model calls no_sqlize without configured fields_column' do
        expect { AnotherModel.create(god: 'Here I am') }.to raise_error(QuantumFields::NoSqlizedFieldsColumnMissing,
                                                                        "another_models should have a `my_json_field` JSON column")
      end
      it 'raises a NoMethodError error when model calls non-sqlizable methods that does not exist' do
        expect { my_instance.do_something! }.to raise_error(NoMethodError)
      end
    end
  end
end
