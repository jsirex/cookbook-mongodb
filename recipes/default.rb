apt_repository 'mongodb-10gen' do
  case node['platform']
  when 'ubuntu'
    uri 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart'
  when 'debian'
    uri 'http://downloads-distro.mongodb.org/repo/debian-sysvinit'
  end
  distribution 'dist'
  components ['10gen']
  keyserver 'keyserver.ubuntu.com'
  key '7F0CEB10'
  action :add
end

file '/etc/default/mongod' do
  action :create_if_missing
  owner 'root'
  content 'ENABLE_MONGOD=no'
end

node['mongodb']['packages'].each do |pkg|
  package pkg do
    version node['mongodb']['version']
    action :install
  end
end
