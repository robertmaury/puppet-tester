require 'spec_helper'
describe 'tester' do

  context 'with defaults for all parameters' do
    it { should contain_class('tester') }
  end
end
