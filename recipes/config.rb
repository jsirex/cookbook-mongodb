include_recipe "mongodb::default"

defaults = node['mongodb']['defaults']
# Process all attributes and setup configuration
MongoDB.each_config(node) do |service_name, conf|
  new_opts = DeepMerge.merge(defaults['opts'], defaults['config'])
  node.default['mongodb']['configs'][service_name] = defaults['service']  
  node.default['mongodb']['configs'][service_name]['opts'] = new_opts

  node.default['mongodb']['configs'][service_name]['install_path'] =
    ::File.join(node['mongodb']['configs'][service_name]['install_prefix'], service_name)
  node.default['mongodb']['configs'][service_name]['opts']['dbpath'] =
      ::File.join(node['mongodb']['configs'][service_name]['install_path'], 
                  node['mongodb']['configs'][service_name]['db_dir'])
  node.default['mongodb']['configs'][service_name]['opts']['logpath'] =
    ::File.join(node['mongodb']['configs'][service_name]['install_path'], 
                node['mongodb']['configs'][service_name]['log_dir'], service_name + '.log')
  node.default['mongodb']['configs'][service_name]['opts']['pidfilepath'] = 
    ::File.join('/var/run/', service_name + '.pid')

  # Internal flags
  node.override['mongodb']['configs'][service_name]['ready_to_install'] = true
end

MongoDB.each_config(node) do |service_name, conf|
  Chef::Log.info("[#{node['mongodb']['cluster_name']}] Found config: #{service_name}")
  mongodb service_name do
    configuration conf
    cluster node['mongodb']['cluster_name']
    type :config
  end
end
