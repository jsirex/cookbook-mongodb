include_recipe "mongodb::default"


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
