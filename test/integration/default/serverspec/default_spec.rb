require 'serverspec'

set :backend, :exec

describe command('/bin/true') do
  it { should return_exit_status 0 }
end
