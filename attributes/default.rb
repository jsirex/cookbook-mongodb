# Which debian package to use
default['mongodb']['package'] = "mongodb-10gen"
default['mongodb']['version'] = "2.4.5" # Latest package 

default['mongodb']['cluster_name'] = "default"


# Default attributes for all type of mongo services
default['mongodb']['defaults']['service']['install_prefix'] = '/usr/local'

# Relative path to mongodb_home
default['mongodb']['defaults']['service']['conf_dir'] = 'etc'
default['mongodb']['defaults']['service']['config_filename'] = 'config.conf'
default['mongodb']['defaults']['service']['log_dir'] = 'log'
default['mongodb']['defaults']['service']['db_dir'] = 'db'
default['mongodb']['defaults']['service']['ready_to_install'] = false




# File options
default['mongodb']['defaults']['opts']['logpath'] = nil # calculated on runtime based on service_name and base_dir
default['mongodb']['defaults']['opts']['dbpath'] = nil # calculated on runtime based on service_name and base_dir
default['mongodb']['defaults']['opts']['pidfilepath'] = nil # calculated on runtime
default['mongodb']['defaults']['opts']['verbose'] = false
default['mongodb']['defaults']['opts']['port'] = 27017
default['mongodb']['defaults']['opts']['objcheck'] = true
default['mongodb']['defaults']['opts']['noobjcheck'] = false
default['mongodb']['defaults']['opts']['cpu'] = false
default['mongodb']['defaults']['opts']['logappend'] = true
default['mongodb']['defaults']['opts']['journal'] = true
default['mongodb']['defaults']['opts']['nojournal'] = false
default['mongodb']['defaults']['opts']['journalCommitInterval'] = 100
default['mongodb']['defaults']['opts']['ipv6'] = false
default['mongodb']['defaults']['opts']['jsonp'] = false
default['mongodb']['defaults']['opts']['noauth'] = true
default['mongodb']['defaults']['opts']['nohttpinterface'] = false
default['mongodb']['defaults']['opts']['noprealloc'] = false
default['mongodb']['defaults']['opts']['noscripting'] = false
default['mongodb']['defaults']['opts']['notablescan'] = false
default['mongodb']['defaults']['opts']['nssize'] = 16
default['mongodb']['defaults']['opts']['rest'] = false
default['mongodb']['defaults']['opts']['slowms'] = 100
default['mongodb']['defaults']['opts']['smallfiles'] = false
default['mongodb']['defaults']['opts']['syncdelay'] = 60 # seconds
default['mongodb']['defaults']['opts']['upgrade'] = false
default['mongodb']['defaults']['opts']['quiet'] = false
default['mongodb']['defaults']['opts']['oplogSize'] = 5120 # megabytes
default['mongodb']['defaults']['opts']['shardsvr'] = false
default['mongodb']['defaults']['opts']['configsvr'] = false




# configs
default['mongodb']['defaults']['config']['port'] = 27019
default['mongodb']['defaults']['config']['configsvr'] = true


## for routers
default['mongodb']['defaults']['router']['port'] = 27018
default['mongodb']['defaults']['router']['configdb'] = ""

# for shards
default['mongodb']['defaults']['shard']['arbiter'] = false
default['mongodb']['defaults']['shard']['shardsvr'] = true





