require 'chefspec'
require 'chefspec/berkshelf'

describe 'skeleton::default' do
  let(:chef_run) { ChefSpec::ChefRunner.new.converge 'skeleton::default' }
  it 'does something' do
    pending 'Your recipe examples goes here.'
  end
end
