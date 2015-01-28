# Support whyrun
def whyrun_supported?
  true
end

action :nothing

action :install do
  conf = new_resource.configuration

  Chef::Log.debug("[#{new_resource.cluster_name}] Found configuration: #{new_resource.name}:")
  conf.each_pair { |k, v| Chef::Log.debug("[#{new_resource.cluster_name}] -> #{k} => #{v}") }

  directory conf['opts']['dbpath'] do
    owner 'mongodb'
    group 'mongodb'
    mode 00755
    recursive true
  end if new_resource.type == :mongod

  directory conf['log_file_prefix'] do
    owner 'mongodb'
    group 'mongodb'
    mode 00755
    recursive true
  end

  directory conf['config_file_prefix'] do
    owner 'mongodb'
    group 'mongodb'
    mode 00755
    recursive true
  end

  directory conf['pid_file_prefix'] do
    owner 'root'
    group 'root'
    mode 00755
    recursive true
  end

  template ::File.join('/etc/logrotate.d', new_resource.name) do
    source 'logrotation.erb'
    owner 'root'
    group 'root'
    mode 00644
    variables :log_file => conf['opts']['logpath']
  end

  template ::File.join('/etc/init.d', new_resource.name) do
    source 'initd.erb'
    owner 'root'
    group 'root'
    mode 00755
    variables :name => new_resource.name,
              :ulimits => conf['ulimits'],
              :type => new_resource.type,
              :config_file => conf['config_file'],
              :pid_file => ::File.join(conf['pid_file_prefix'], new_resource.name)
  end

  template conf['config_file'] do
    source 'mongodb.conf.erb'
    owner 'mongodb'
    group 'mongodb'
    mode 00644
    variables :cluster => new_resource.cluster_name,
              :type => new_resource.type,
              :options => conf['opts']
    notifies :restart, "service[#{new_resource.name}]"
  end

  service new_resource.name do
    supports :status => true, :restart => true
    action [:enable, :start]
  end
end
