require 'spec_helper'
require 'quantum_fields'

RSpec.describe QuantumFields do
  describe ActiveRecord::Base do
    it { expect(described_class).to respond_to(:no_sqlize) }
  end
end
