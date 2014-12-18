require 'spec_helper'

describe 'mongodb::default' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new.converge described_recipe
  end

  it 'is pending' do
    pending('Implement your tests here')
    fail
  end
end
