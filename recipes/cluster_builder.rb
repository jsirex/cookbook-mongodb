node.override['build_essential']['compiletime'] = true
include_recipe "build-essential"

include_recipe "mongodb::_search"

chef_gem 'bson_ext'
chef_gem 'mongo'

cluster_name = node['mongodb']['cluster_name']

Chef::Log.info("[cluster_builder] Found cluster: #{cluster_name}")

shard_nodes = search(:node, node['mongodb']['search']['shards'])

shards = Hash.new
shard_nodes.each do |s_node|
  MongoDB.each_shard(s_node) do |shard_name|
  shards[shard_name] ||= []
    MongoDB.each_shard_server(s_node, shard_name) do |service_name, conf|
      shards[shard_name] << "#{s_node['fqdn']}:#{conf['opts']['port']}"
    end
  end
end

# Building or updating replica for each shard and thiers servers
shards.each_pair do |shard_name, servers|
  servers.sort!
  Chef::Log.info("[cluster_builder] Shard #{shard_name}: #{servers.inspect}")

  case MongoDB.check_replicaset_status(shard_name, servers)
  when :ok then Chef::Log.info("[cluster_builder] [#{cluster_name}] Replication #{shard_name} already initialized.")
  when :conf then
    Chef::Log.info("[cluster_builder] [#{cluster_name}] Scheduling initialization of replicaset: #{shard_name}.")
    ruby_block "initialize_#{shard_name}_replicaset" do
      block do
        MongoDB.configure_replicaset(cluster_name, shard_name, servers)
      end
      action :create
    end
  when :reconf
    Chef::Log.info("[cluster_builder] [#{cluster_name}] Scheduling reconfiguration of replicaset: #{shard_name}.")
    ruby_block "reconfigure_#{shard_name}_replicaset" do
      block do
        MongoDB.reconfigure_replicaset(cluster_name, shard_name, servers)
      end
      action :create
    end
  end # case
end

# Updating Shards
router_nodes = search(:node, node['mongodb']['search']['routers'])
routers = []
router_nodes.each do |r_node|
  MongoDB.each_router(r_node) do |router_name, conf|
    routers << "#{r_node['fqdn']}:#{conf['opts']['port']}"
  end
end

router = nil
routers.each do |r|
  if MongoDB.server_available?(r)
    router = r
    break
  end
end

if router
  existing_shards = MongoDB.get_existing_shards(cluster_name, router)
  new_shards = shards.dup
  new_shards.delete_if {|k,v| existing_shards.include?(k)}
  Chef::Log.info("[cluster_builder] [#{cluster_name}] No new shards were found") if new_shards.empty?
  new_shards.each_pair do |shard_name, servers|
    Chef::Log.info("[cluster_builder] [#{cluster_name}] Found new shard: #{shard_name}")
    ruby_block "add_#{shard_name}_shard" do
      block do
        MongoDB.add_shard(cluster_name, router, shard_name, servers)
      end
      action :create
    end
  end
else
  Chef::Log.warn("[#{cluster_name}] Could not connect to any router. Give up!")
end

