defaults = node['mongodb']['defaults']

# Eval defaults

MongoDB.each_single(node) do |service_name, conf|
  node.default['mongodb']['singles'][service_name] = defaults['service']
  node.default['mongodb']['singles'][service_name]['opts'] = DeepMerge.merge(defaults['opts'], defaults['single'])  
end

MongoDB.each_config(node) do |service_name, conf|
  node.default['mongodb']['configs'][service_name] = defaults['service']
  node.default['mongodb']['configs'][service_name]['opts'] = DeepMerge.merge(defaults['opts'], defaults['config'])
end

MongoDB.each_router(node) do |service_name, conf|
  node.default['mongodb']['routers'][service_name] = defaults['service']  
  node.default['mongodb']['routers'][service_name]['opts'] = DeepMerge.merge(defaults['opts'], defaults['router'])
end

MongoDB.each_shard(node) do |shard_name|
  MongoDB.each_shard_server(node, shard_name) do |service_name, conf|
    node.default['mongodb']['shards'][shard_name][service_name] = defaults['service']
    node.default['mongodb']['shards'][shard_name][service_name]['opts'] = DeepMerge.merge(defaults['opts'], defaults['shard'])
  end
end

# Only After all defaults have been aplied calculate all things
MongoDB.each_single(node) do |service_name, conf|  
  node.default['mongodb']['singles'][service_name]['config_file'] = ::File.join(conf['config_file_prefix'], service_name + '.conf')   
  node.default['mongodb']['singles'][service_name]['opts']['logpath'] = ::File.join(conf['log_file_prefix'], service_name + '.log') 
  node.default['mongodb']['singles'][service_name]['opts']['pidfilepath'] = ::File.join(conf['pid_file_prefix'], service_name) 
  node.default['mongodb']['singles'][service_name]['opts']['dbpath'] = ::File.join(conf['data_dir_prefix'], service_name) 
end

MongoDB.each_config(node) do |service_name, conf|  
  node.default['mongodb']['configs'][service_name]['config_file'] = ::File.join(conf['config_file_prefix'], service_name + '.conf')   
  node.default['mongodb']['configs'][service_name]['opts']['logpath'] = ::File.join(conf['log_file_prefix'], service_name + '.log') 
  node.default['mongodb']['configs'][service_name]['opts']['pidfilepath'] = ::File.join(conf['pid_file_prefix'], service_name) 
  node.default['mongodb']['configs'][service_name]['opts']['dbpath'] = ::File.join(conf['data_dir_prefix'], service_name) 
end

MongoDB.each_router(node) do |service_name, conf|  
  node.default['mongodb']['routers'][service_name]['config_file'] = ::File.join(conf['config_file_prefix'], service_name + '.conf')
  node.default['mongodb']['routers'][service_name]['opts']['logpath'] = ::File.join(conf['log_file_prefix'], service_name + '.log') 
  node.default['mongodb']['routers'][service_name]['opts']['pidfilepath'] = ::File.join(conf['pid_file_prefix'], service_name)   
end

MongoDB.each_shard(node) do |shard_name|
  MongoDB.each_shard_server(node, shard_name) do |service_name, conf|
    node.default['mongodb']['shards'][shard_name][service_name]['config_file'] = ::File.join(conf['config_file_prefix'], service_name + '.conf')   
    node.default['mongodb']['shards'][shard_name][service_name]['opts']['logpath'] = ::File.join(conf['log_file_prefix'], service_name + '.log') 
    node.default['mongodb']['shards'][shard_name][service_name]['opts']['pidfilepath'] = ::File.join(conf['pid_file_prefix'], service_name) 
    node.default['mongodb']['shards'][shard_name][service_name]['opts']['dbpath'] = ::File.join(conf['data_dir_prefix'], service_name)
    node.default['mongodb']['shards'][shard_name][service_name]['opts']['replSet'] = shard_name
    
    # Populate rs.conf() settings for shard
    node.default['mongodb']['shards'][shard_name][service_name]['rs_member_conf']['host'] = [
      conf['use_fqdn'] ? node['fqdn'] : node['ipaddress'],
      conf['opts']['port']
    ].join(':')
    
    if conf['arbiter'] then
      node.default['mongodb']['shards'][shard_name][service_name]['rs_member_conf']['arbiterOnly'] = true
      node.default['mongodb']['shards'][shard_name][service_name]['opts']['nohttpinterface'] = true
      node.default['mongodb']['shards'][shard_name][service_name]['opts']['smallfiles'] = true
      node.default['mongodb']['shards'][shard_name][service_name]['opts']['nojournal'] = true
      node.default['mongodb']['shards'][shard_name][service_name]['opts']['oplogSize'] = 8      
    end
  end
end
