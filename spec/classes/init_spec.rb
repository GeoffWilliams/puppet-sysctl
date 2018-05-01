require 'spec_helper'
describe 'sysctl' do
  context 'with default values for all parameters' do
    it { should contain_class('sysctl') }
  end
end
