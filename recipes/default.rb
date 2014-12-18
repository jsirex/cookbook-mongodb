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
#  notifies :run, 'execute[apt-get update]', :immediately
end

file '/etc/default/mongodb' do
  action :create_if_missing
  owner 'root'
  content 'ENABLE_MONGODB=no'
end

package node['mongodb']['package'] do
  version node['mongodb']['version']
  action :install
end
