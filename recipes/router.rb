include_recipe 'mongodb::default'
include_recipe 'mongodb::_search'

defaults = node['mongodb']['defaults']

MongoDB.each_router(node) do |service_name, _conf|
  node.default['mongodb']['routers'][service_name] = defaults['service']
  node.default['mongodb']['routers'][service_name]['opts'] = DeepMerge.merge(defaults['opts'], defaults['router'])
end

MongoDB.each_router(node) do |service_name, conf|
  node.default['mongodb']['routers'][service_name]['config_file'] = ::File.join(conf['config_file_prefix'], service_name + '.conf')
  node.default['mongodb']['routers'][service_name]['opts']['logpath'] = ::File.join(conf['log_file_prefix'], service_name + '.log')
end

cn = node['mongodb']['cluster_name']
config_nodes = search(:node, node['mongodb']['search']['configs'])

config_servers = []
config_nodes.each do |c_node|
  MongoDB.each_config(c_node) do |service_name, conf|
    Chef::Log.info("[#{cn}] Router meet config #{service_name}: #{c_node[:fqdn]}:#{conf['opts']['port']}")
    config_servers << "#{c_node['fqdn']}:#{conf['opts']['port']}"
  end
end

if config_servers.length < 3
  Chef::Log.warn("[#{cn}] Found #{config_servers.length} config servers alive. Required exactly 3 MongoDB Config Servers.")
  Chef::Log.warn("[#{cn}] Skipping MongoDB::Router(mongos).")
  Chef::Log.warn("[#{cn}] Config servers list: #{config_servers.inspect}")

elsif config_servers.length > 3
  Chef::Log.error("[#{cn}] Found #{config_servers.length}. But required only 3. Don't know which to use. Give up.")
  Chef::Log.error("[#{cn}] Config servers list: #{config_servers.inspect}")
else
  MongoDB.each_router(node) do |service_name, _conf|
    Chef::Log.info("[#{cn}] Found router: #{service_name}")
    node.override['mongodb']['routers'][service_name]['opts']['configdb'] = config_servers.sort.join(',')
    mongodb service_name do
      configuration node['mongodb']['routers'][service_name]
      cluster_name cn
      type :mongos
    end
  end
end
