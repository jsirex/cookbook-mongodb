include_recipe 'mongodb::default'

defaults = node['mongodb']['defaults']

MongoDB.each_shard(node) do |shard_name|
  MongoDB.each_shard_server(node, shard_name) do |service_name, _conf|
    node.default['mongodb']['shards'][shard_name][service_name] = defaults['service']
    node.default['mongodb']['shards'][shard_name][service_name]['opts'] = DeepMerge.merge(defaults['opts'], defaults['shard'])
  end
end

MongoDB.each_shard(node) do |shard_name|
  MongoDB.each_shard_server(node, shard_name) do |service_name, conf|
    node.default['mongodb']['shards'][shard_name][service_name]['config_file'] = ::File.join(conf['config_file_prefix'], service_name + '.conf')
    node.default['mongodb']['shards'][shard_name][service_name]['opts']['logpath'] = ::File.join(conf['log_file_prefix'], service_name + '.log')
    node.default['mongodb']['shards'][shard_name][service_name]['opts']['dbpath'] = ::File.join(conf['data_dir_prefix'], service_name)
    node.default['mongodb']['shards'][shard_name][service_name]['opts']['replSet'] = shard_name

    # Populate rs.conf() settings for shard
    node.default['mongodb']['shards'][shard_name][service_name]['rs_member_conf']['host'] = [
      conf['use_fqdn'] ? node['fqdn'] : node['ipaddress'],
      conf['opts']['port']
    ].join(':')

    if conf['arbiter']
      node.default['mongodb']['shards'][shard_name][service_name]['rs_member_conf']['arbiterOnly'] = true
      node.default['mongodb']['shards'][shard_name][service_name]['opts']['nohttpinterface'] = true
      node.default['mongodb']['shards'][shard_name][service_name]['opts']['smallfiles'] = true
      node.default['mongodb']['shards'][shard_name][service_name]['opts']['nojournal'] = true
      node.default['mongodb']['shards'][shard_name][service_name]['opts']['oplogSize'] = 8
    end
  end
end

MongoDB.each_shard(node) do |shard_name|
  Chef::Log.info("[#{node['mongodb']['cluster_name']}] Found shard: #{shard_name}")
  MongoDB.each_shard_server(node, shard_name) do |service_name, conf|
    Chef::Log.info("[#{node['mongodb']['cluster_name']}] Found shard node: #{service_name}")
    Chef::Log.debug("[#{node['mongodb']['cluster_name']}] #{service_name} configuration:")
    Chef::Log.debug("#{conf.pretty_inspect}")
    mongodb service_name do
      configuration conf
      cluster_name node['mongodb']['cluster_name']
      type :mongod
    end
  end
end
