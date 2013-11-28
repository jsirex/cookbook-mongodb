# Which debian package to use
default['mongodb']['package'] = "mongodb-10gen"
default['mongodb']['version'] = "2.4.8" # Latest package

default['mongodb']['cluster_name'] = "default"


# Default attributes for all type of mongo services
default['mongodb']['defaults']['service']['install_prefix'] = '/usr/local'

# Relative path to mongodb_home
default['mongodb']['defaults']['service']['conf_dir'] = 'etc'
default['mongodb']['defaults']['service']['log_dir'] = 'log'
default['mongodb']['defaults']['service']['db_dir'] = 'db'

default['mongodb']['defaults']['service']['config_filename'] = 'config.conf'
# this marker for search
default['mongodb']['defaults']['service']['ready_to_install'] = false

# File options
default['mongodb']['defaults']['opts']['logpath'] = nil # calculated on runtime based on service_name and base_dir
default['mongodb']['defaults']['opts']['dbpath'] = nil # calculated on runtime based on service_name and base_dir
default['mongodb']['defaults']['opts']['pidfilepath'] = nil # calculated on runtime
default['mongodb']['defaults']['opts']['logappend'] = true

