# Calculate on runtime search queries
cluster_name = node['mongodb']['cluster_name']
query = []
query << "chef_environment:#{node.chef_environment}"
query << "mongodb_cluster_name:#{cluster_name}"
query << "mongodb_shards*:*"
# String used to search for config servers
node.default['mongodb']['search']['shards'] = query.join(" AND ")

# String used to search for routers servers
query = []
query << "chef_environment:#{node.chef_environment}"
query << "mongodb_cluster_name:#{cluster_name}"
query << "mongodb_configs*:*"
node.default['mongodb']['search']['configs'] = query.join(" AND ")

# Routers
query = []
query << "chef_environment:#{node.chef_environment}"
query << "mongodb_cluster_name:#{cluster_name}"
query << "mongodb_routers*:*"
node.default['mongodb']['search']['routers'] = query.join(" AND ")


# All nodes in cluster
query = []
query << "chef_environment:#{node.chef_environment}"
query << "mongodb_cluster_name:#{cluster_name}"
query << "NOT fqdn:#{node['fqdn']}"
node.default['mongodb']['search']['all'] = query.join(" AND ")