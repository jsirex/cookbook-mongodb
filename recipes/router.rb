include_recipe "mongodb::default"
include_recipe "mongodb::_search"


cluster_name = node['mongodb']['cluster_name']
config_nodes = search(:node, node['mongodb']['search']['configs'])

config_servers = []
config_nodes.each do |c_node|
  MongoDB.each_config(c_node) do |service_name, conf|
    Chef::Log.info("[#{cluster_name}] Router meet config #{service_name}: #{c_node[:fqdn]}:#{conf['opts']['port']}")
    config_servers << "#{c_node['fqdn']}:#{conf['opts']['port']}"
  end
end

if config_servers.length < 3
  Chef::Log.warn("[#{cluster_name}] Found #{config_servers.length} config servers alive. Required exactly 3 MongoDB Config Servers.")
  Chef::Log.warn("[#{cluster_name}] Skipping MongoDB::Router(mongos).")
  Chef::Log.warn("[#{cluster_name}] Config servers list: #{config_servers.inspect}")

elsif config_servers.length > 3
  Chef::Log.error("[#{cluster_name}] Found #{config_servers.length}. But required only 3. Don't know which to use. Give up.")
  Chef::Log.error("[#{cluster_name}] Config servers list: #{config_servers.inspect}")
else
  MongoDB.each_router(node) do |service_name, conf|
    Chef::Log.info("[#{cluster_name}] Found router: #{service_name}")
    node.override['mongodb']['routers'][service_name]['opts']['configdb'] = config_servers.sort.join(',')
    mongodb service_name do
      configuration node['mongodb']['routers'][service_name]
      cluster cluster_name
      type :router
    end
  end
end
