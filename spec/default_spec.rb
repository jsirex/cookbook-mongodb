require 'spec_helper'

describe 'mongodb::default' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new.converge described_recipe
  end

  it 'adds apt repository for mongodb' do
    expect(chef_run).to add_apt_repository('mongodb-10gen')
  end

  [
    'mongodb-org-mongos',
    'mongodb-org-server',
    'mongodb-org-shell',
    'mongodb-org-tools'
  ].each do |pkg|
    it "installs package #{pkg}" do
      expect(chef_run).to install_package(pkg)
    end    
  end
end
