include_recipe "mongodb::default"

MongoDB.each_config(node) do |service_name, conf|
  Chef::Log.info("[#{node['mongodb']['cluster_name']}] Found config: #{service_name}")
  mongodb service_name do
    configuration conf
    cluster_name node['mongodb']['cluster_name']
    type :mongod
  end
end
