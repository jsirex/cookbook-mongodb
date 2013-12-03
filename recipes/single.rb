include_recipe "mongodb::default"

MongoDB.each_single(node) do |service_name, conf|
  Chef::Log.info("[#{node['mongodb']['cluster_name']}] Found single: #{service_name}")
  mongodb service_name do
    configuration conf
    cluster_name node['mongodb']['cluster_name']
    type :mongod
  end
  
end
