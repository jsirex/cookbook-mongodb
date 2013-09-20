include_recipe "mongodb::default"
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

MongoDB.each_shard(node) do |shard_name|
  Chef::Log.info("[#{node['mongodb']['cluster_name']}] Found shard: #{shard_name}")
  MongoDB.each_shard_server(node, shard_name) do |service_name, conf|
    Chef::Log.info("[#{node['mongodb']['cluster_name']}] Found shard node: #{service_name}")
    mongodb service_name do
      configuration conf
      cluster node['mongodb']['cluster_name']
      repl_set shard_name
      type :shard
    end
  end
end
