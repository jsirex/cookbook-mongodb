# Which debian package to use
default['mongodb']['package'] = "mongodb-10gen"
default['mongodb']['version'] = "2.4.8" # Latest package

default['mongodb']['cluster_name'] = "default"


# Default attributes for all type of mongo services
default['mongodb']['defaults']['service']['data_dir_prefix'] = '/var/lib'
default['mongodb']['defaults']['service']['log_file_prefix'] = '/var/log/mongodb'
default['mongodb']['defaults']['service']['config_file_prefix'] = '/etc/mongodb'
default['mongodb']['defaults']['service']['pid_file_prefix'] = '/var/run'
# Use fqdn or ip in rs.conf()
default['mongodb']['defaults']['service']['use_fqdn'] = false

# Currently, plain text ulimits settings passed to initd script ulimit command
# May be a security hole if somebody adds custom commands like ';rm -rf /var/log'
default['mongodb']['defaults']['service']['ulimits'] = [
  "-f unlimited",
  "-t unlimited",
  "-v unlimited",
  "-n 64000",
  "-m unlimited",
  "-u 32000"
]


default['mongodb']['defaults']['opts']['logappend'] = true

