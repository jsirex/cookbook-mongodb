require 'socket'

include_recipe 'iptables'
include_recipe 'mongodb::_search'

cluster_name = node['mongodb']['cluster_name']
# Get list of other clusted nodes:
remote_nodes = search(:node, node['mongodb']['search']['all'])

services_list = {}
allowed_ips = remote_nodes.map { |n| n['ipaddress'] }

# Load allow list from databag
# TODO need a way to rebuild firewall more nice way for external services
allowed_clients = data_bag_item(:mongodb, 'allowed_clients') rescue nil
unless allowed_clients.nil? || allowed_clients[node.chef_environment].nil?
  ips = [allowed_clients[node.chef_environment]].flatten.map { |client| Socket.getaddrinfo(client, nil).first[3] }
  allowed_ips += ips
  Chef::Log.info("Custom allowed clients: #{[allowed_clients[node.chef_environment]].flatten.join(', ')}")
end

# Configs
MongoDB.each_config(node) do |service_name, conf|
  services_list[service_name] = conf['opts']['port']
end

# Routers
MongoDB.each_router(node) do |service_name, conf|
  services_list[service_name] = conf['opts']['port']
end

MongoDB.each_shard(node) do |shard_name|
  MongoDB.each_shard_server(node, shard_name) do |service_name, conf|
    services_list[service_name] = conf['opts']['port']
  end
end

iptables_rule "mongodb_#{cluster_name}" do
  source 'mongodb_firewall.erb'
  variables :allowed_ips => allowed_ips, :services_list => services_list
end
