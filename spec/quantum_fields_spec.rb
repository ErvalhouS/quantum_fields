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
end

RSpec.describe QuantumFields do
  describe ActiveRecord::Base do
    it { expect(described_class).to respond_to(:no_sqlize) }

    describe "basic adapter json field capability" do
      let(:my_instance) { MyModel.create(my_json_field: { a_column_that_does_not_exists: 'I do exist'}) }

      it "persist a property in a json field" do
        expect(my_instance.my_json_field["a_column_that_does_not_exists"]).to eq "I do exist"
      end
    end
  end
end
