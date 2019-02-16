require 'spec_helper'
require 'quantum_fields'

RSpec.describe QuantumFields do
  it { expect(ActiveRecord::Base).to respond_to(:no_sqlize) }
end
