action :nothing

action :install do  
  
  Chef::Log.debug("[#{new_resource.cluster_name}] Found configuration: #{new_resource.name}:")
  conf.each_pair {|k,v| Chef::Log.debug("[#{new_resource.cluster_name}] -> #{k} => #{v}")}

  data_dir = ::File.join(new_resource.configuration['data_dir_prefix'], new_resource.name) 
  log_dir = ::File.join(new_resource.configuration['log_dir_prefix'], new_resource.name) 
  config_file = ::File.join(new_resource.configuration['config_file_prefix'], new_resource.name + '.conf')
  pid_file = ::File.join(new_resource.configuration['pid_file_prefix'], new_resource.name)
   
   
  directory data_dir do
    owner "mongodb"
    group "mongodb"
    mode 00755
    recursive true
  end
  
  directory log_dir do
    owner "mongodb"
    group "mongodb"
    mode 00755
    recursive true
  end
  
  directory new_resource.configuration['config_file_prefix'] do
    owner "mongodb"
    group "mongodb"
    mode 00755
    recursive true
  end
  
  directory new_resource.configuration['pid_file_prefix'] do
    owner "root"
    group "root"
    mode 00755
    recursive true
  end

  template ::File.join("/etc/logrotate.d", new_resource.name) do
    source "logrotation.erb"
    owner "root"
    group "root"
    mode 00644
    variables :log_dir => log_dir
  end

  template ::File.join("/etc/init.d", new_resource.name) do
    source "initd.erb"
    owner "root"
    group "root"
    mode 00755
    variables :name => new_resource.name, 
              :ulimits => new_resource.configuration['ulimits'], 
              :binary => new_resource.binary,
              :config_file => config_file,
              :pid_file => pid_file 
  end

  template config_file do
    source "mongodb.conf.erb"
    owner "mongodb"
    group "mongodb"
    mode 00644
    variables :cluster => new_resource.cluster, 
              :binary => new_resource.binary,
              :options => new_resource.configuration['opts']              
    notifies :restart, "service[#{new_resource.name}]"
  end

  service new_resource.name do
    supports :status => true
    action :enable
  end

end