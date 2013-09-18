action :nothing

# Some options by default not valid in router configuration. Just remove it from configuration
def filter_router_options(opts)
  opts.delete 'dbpath'
  opts.delete 'journal'
  opts.delete 'nojournal'
  opts.delete 'journalCommitInterval'
  opts.delete 'noauth'
  opts.delete 'nssize'
  opts.delete 'slowms'
  opts.delete 'smallfiles'
  opts.delete 'syncdelay'
  opts.delete 'oplogSize'
  opts.delete 'shardsvr'
  opts
end

action :install do
  return unless new_resource.configuration['ready_to_install']

  conf = new_resource.configuration.to_hash
  conf['opts'] = conf['opts'].to_hash
  Chef::Log.debug("[#{new_resource.cluster}] Found configuration: #{new_resource.name}:")
  conf.each_pair {|k,v| Chef::Log.debug("[#{new_resource.cluster}] -> #{k} => #{v}")}

  # Configuration options
  conf['opts']['dbpath'] ||= ::File.join(conf['install_path'], conf['db_dir'])
  conf['opts']['logpath'] ||= ::File.join(conf['install_path'], conf['log_dir'], new_resource.name + '.log')
  conf['opts']['pidfilepath'] ||= "/var/run/#{new_resource.name}.pid"

  conf_path = ::File.join(conf['install_path'], conf['conf_dir'], conf['config_filename'])

  directory conf['install_path'] do
    owner "mongodb"
    group "mongodb"
    mode 00700
    recursive true
  end

  directory ::File.dirname(conf_path) do
    owner "mongodb"
    group "mongodb"
    mode 00700
  end

  directory ::File.dirname(conf['opts']['logpath']) do
    owner "mongodb"
    group "mongodb"
    mode 00755
  end

  directory conf['opts']['dbpath'] do
    owner "mongodb"
    group "mongodb"
    mode 00700
  end

  template ::File.join("/etc/logrotate.d", new_resource.name) do
    source "logrotation.erb"
    owner "root"
    group "root"
    mode 00644
    variables :options => conf['opts']
  end

  template ::File.join("/etc/init.d", new_resource.name) do
    source "initd.erb"
    owner "root"
    group "root"
    mode 00755
    variables :name => new_resource.name, :options => conf['opts'], :type => new_resource.type, :conf_path => conf_path
  end

  case new_resource.type
  when :router then conf['opts'] = filter_router_options(conf['opts'])
  when :shard then conf['opts']['replSet'] = new_resource.repl_set || "default"
  end
  template conf_path do
    source "mongodb.conf.erb"
    owner "mongodb"
    group "mongodb"
    mode 00600
    variables :options => conf['opts'], :cluster => new_resource.cluster, :type => new_resource.type
    notifies :restart, "service[#{new_resource.name}]"
  end

  service new_resource.name do
    action :enable
  end

end