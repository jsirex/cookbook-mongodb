include_recipe "mongodb::default"
defaults = node['mongodb']['defaults']

MongoDB.each_single(node) do |service_name, conf|
  new_opts = DeepMerge.merge(defaults['opts'], defaults['single'])
  node.default['mongodb']['singles'][service_name] = defaults['service']  
  node.default['mongodb']['singles'][service_name]['opts'] = new_opts

  node.default['mongodb']['singles'][service_name]['install_path'] =
    ::File.join(node['mongodb']['singles'][service_name]['install_prefix'], service_name)
  node.default['mongodb']['singles'][service_name]['opts']['dbpath'] =
      ::File.join(node['mongodb']['singles'][service_name]['install_path'], 
                  node['mongodb']['singles'][service_name]['db_dir'])
  node.default['mongodb']['singles'][service_name]['opts']['logpath'] =
    ::File.join(node['mongodb']['singles'][service_name]['install_path'], 
                node['mongodb']['singles'][service_name]['log_dir'], service_name + '.log')
  node.default['mongodb']['singles'][service_name]['opts']['pidfilepath'] = 
    ::File.join('/var/run/', service_name + '.pid')

  # Internal flags
  node.override['mongodb']['singles'][service_name]['ready_to_install'] = true
end

MongoDB.each_single(node) do |service_name, conf|
  Chef::Log.info("[#{node['mongodb']['cluster_name']}] Found single: #{service_name}")
  mongodb service_name do
    configuration conf
    cluster node['mongodb']['cluster_name']
    type :single
  end
end
