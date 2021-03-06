include_recipe 'mongodb::default'

defaults = node['mongodb']['defaults']

# Eval defaults

MongoDB.each_single(node) do |service_name, _conf|
  node.default['mongodb']['singles'][service_name] = defaults['service']
  node.default['mongodb']['singles'][service_name]['opts'] = DeepMerge.merge(defaults['opts'], defaults['single'])
end

# Only After all defaults have been aplied calculate all things
MongoDB.each_single(node) do |service_name, conf|
  node.default['mongodb']['singles'][service_name]['config_file'] = ::File.join(conf['config_file_prefix'], service_name + '.conf')
  node.default['mongodb']['singles'][service_name]['opts']['logpath'] = ::File.join(conf['log_file_prefix'], service_name + '.log')
  node.default['mongodb']['singles'][service_name]['opts']['dbpath'] = ::File.join(conf['data_dir_prefix'], service_name)
end

MongoDB.each_single(node) do |service_name, conf|
  Chef::Log.info("[#{node['mongodb']['cluster_name']}] Found single: #{service_name}")
  mongodb service_name do
    configuration conf
    cluster_name node['mongodb']['cluster_name']
    type :mongod
  end
end
