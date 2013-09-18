include_recipe "apt"

apt_repository "mongodb-10gen" do
  case node["platform"]
  when "ubuntu"
    uri "http://downloads-distro.mongodb.org/repo/ubuntu-upstart"
  when "debian"
    uri "http://downloads-distro.mongodb.org/repo/debian-sysvinit"
  end
  distribution "dist"
  components ["10gen"]
  keyserver "keyserver.ubuntu.com"
  key "7F0CEB10"
  action :add
  notifies :run, "execute[apt-get update]", :immediately  # recipe[apt::default]
end

file "/etc/default/mongodb" do
  action :create_if_missing
  owner "root"
  content "ENABLE_MONGODB=no"
end

Chef::Application.fatal! "Cookbook requires node['mongodb']['version'] to be explicity defined!", 100 unless node['mongodb']['version']

package node['mongodb']['package'] do
  version node['mongodb']['version']
  action :install
end

defaults = node['mongodb']['defaults']
# Process all attributes and setup configuration
# configure shards attrs
MongoDB.each_shard(node) do |shard_name|
  MongoDB.each_shard_server(node, shard_name) do |service_name, conf|
    new_opts = DeepMerge.merge(defaults['opts'], defaults['shard'])
    node.default['mongodb']['shards'][shard_name][service_name] = defaults['service']    
    node.default['mongodb']['shards'][shard_name][service_name]['opts'] = new_opts

    node.default['mongodb']['shards'][shard_name][service_name]['install_path'] =
      ::File.join(node['mongodb']['shards'][shard_name][service_name]['install_prefix'], service_name)

    node.default['mongodb']['shards'][shard_name][service_name]['opts']['dbpath'] =
      ::File.join(node['mongodb']['shards'][shard_name][service_name]['install_path'], 
                  node['mongodb']['shards'][shard_name][service_name]['db_dir'])
    node.default['mongodb']['shards'][shard_name][service_name]['opts']['logpath'] =
      ::File.join(node['mongodb']['shards'][shard_name][service_name]['install_path'], 
                  node['mongodb']['shards'][shard_name][service_name]['log_dir'], service_name + '.log')
    node.default['mongodb']['shards'][shard_name][service_name]['opts']['pidfilepath'] = 
      ::File.join('/var/run/', service_name + '.pid')
    

    # Internal flags
    node.override['mongodb']['shards'][shard_name][service_name]['ready_to_install'] = true
  end
end

# configure config attrs
MongoDB.each_config(node) do |service_name, conf|
  new_opts = DeepMerge.merge(defaults['opts'], defaults['config'])
  node.default['mongodb']['configs'][service_name] = defaults['service']  
  node.default['mongodb']['configs'][service_name]['opts'] = new_opts

  node.default['mongodb']['configs'][service_name]['install_path'] =
    ::File.join(node['mongodb']['configs'][service_name]['install_prefix'], service_name)
  node.default['mongodb']['configs'][service_name]['opts']['dbpath'] =
      ::File.join(node['mongodb']['configs'][service_name]['install_path'], 
                  node['mongodb']['configs'][service_name]['db_dir'])
  node.default['mongodb']['configs'][service_name]['opts']['logpath'] =
    ::File.join(node['mongodb']['configs'][service_name]['install_path'], 
                node['mongodb']['configs'][service_name]['log_dir'], service_name + '.log')
  node.default['mongodb']['configs'][service_name]['opts']['pidfilepath'] = 
    ::File.join('/var/run/', service_name + '.pid')

  # Internal flags
  node.override['mongodb']['configs'][service_name]['ready_to_install'] = true
end

# configure routers attrs
MongoDB.each_router(node) do |service_name, conf|
  new_opts = DeepMerge.merge(defaults['opts'], defaults['router'])
  node.default['mongodb']['routers'][service_name] = defaults['service']  
  node.default['mongodb']['routers'][service_name]['opts'] = new_opts

  node.default['mongodb']['routers'][service_name]['install_path'] =
    ::File.join(node['mongodb']['routers'][service_name]['install_prefix'], service_name)
  
  node.default['mongodb']['routers'][service_name]['opts']['dbpath'] =
    ::File.join(node['mongodb']['routers'][service_name]['install_path'], 
                node['mongodb']['routers'][service_name]['db_dir'])
  node.default['mongodb']['routers'][service_name]['opts']['logpath'] =
    ::File.join(node['mongodb']['routers'][service_name]['install_path'], 
                node['mongodb']['routers'][service_name]['log_dir'], service_name + '.log')
  node.default['mongodb']['routers'][service_name]['opts']['pidfilepath'] = 
    ::File.join('/var/run/', service_name + '.pid')


  # Internal flags
  node.override['mongodb']['routers'][service_name]['ready_to_install'] = true
end


