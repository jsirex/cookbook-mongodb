require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe command('/bin/true') do
  it { should return_exit_status 0 }
end
