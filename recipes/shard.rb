include_recipe "mongodb::default"
# Process all attributes and setup configuration
# configure shards attrs


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
