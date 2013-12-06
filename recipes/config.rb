include_recipe "mongodb::default"

defaults = node['mongodb']['defaults']

MongoDB.each_config(node) do |service_name, conf|
  node.default['mongodb']['configs'][service_name] = defaults['service']
  node.default['mongodb']['configs'][service_name]['opts'] = DeepMerge.merge(defaults['opts'], defaults['config'])
end

MongoDB.each_config(node) do |service_name, conf|  
  node.default['mongodb']['configs'][service_name]['config_file'] = ::File.join(conf['config_file_prefix'], service_name + '.conf')   
  node.default['mongodb']['configs'][service_name]['opts']['logpath'] = ::File.join(conf['log_file_prefix'], service_name + '.log') 
  node.default['mongodb']['configs'][service_name]['opts']['pidfilepath'] = ::File.join(conf['pid_file_prefix'], service_name) 
  node.default['mongodb']['configs'][service_name]['opts']['dbpath'] = ::File.join(conf['data_dir_prefix'], service_name) 
end

MongoDB.each_config(node) do |service_name, conf|
  Chef::Log.info("[#{node['mongodb']['cluster_name']}] Found config: #{service_name}")
  mongodb service_name do
    configuration conf
    cluster_name node['mongodb']['cluster_name']
    type :mongod
  end
end
