# Description

This is default description for your cookbook.
Find me in \<GIT_ROOT\>/doc/

# Requirements

## Platform:

* Debian

## Cookbooks:

* apt
* iptables
* build-essential

# Attributes

* `node['mongodb']['defaults']['config']['port']` -  Defaults to `"27019"`.
* `node['mongodb']['defaults']['config']['configsvr']` -  Defaults to `"true"`.
* `node['mongodb']['packages']` -  Defaults to `"[ ... ]"`.
* `node['mongodb']['version']` -  Defaults to `"2.6.6"`.
* `node['mongodb']['cluster_name']` -  Defaults to `"default"`.
* `node['mongodb']['defaults']['service']['data_dir_prefix']` -  Defaults to `"/var/lib"`.
* `node['mongodb']['defaults']['service']['log_file_prefix']` -  Defaults to `"/var/log/mongodb"`.
* `node['mongodb']['defaults']['service']['config_file_prefix']` -  Defaults to `"/etc/mongodb"`.
* `node['mongodb']['defaults']['service']['pid_file_prefix']` -  Defaults to `"/var/run"`.
* `node['mongodb']['defaults']['service']['use_fqdn']` -  Defaults to `"true"`.
* `node['mongodb']['defaults']['service']['ulimits']` -  Defaults to `"[ ... ]"`.
* `node['mongodb']['defaults']['opts']['logappend']` -  Defaults to `"true"`.
* `node['mongodb']['defaults']['opts']['port']` -  Defaults to `"27017"`.
* `node['mongodb']['defaults']['router']['port']` -  Defaults to `"27017"`.
* `node['mongodb']['defaults']['router']['configdb']` -  Defaults to `""`.
* `node['mongodb']['defaults']['shard']['shardsvr']` -  Defaults to `"true"`.
* `node['mongodb']['defaults']['shard']['port']` -  Defaults to `"27018"`.

# Recipes

* mongodb::default - Installs default mongodb package without startup
* mongodb::single - Installs mongodb as standalone server
* mongodb::config - Installs mongodb as config server
* mongodb::router - Installs mongodb as mongos router
* mongodb::shard - Installs mongodb as shard
* mongodb::firewall - Enables firewall on all mongodb ports
* mongodb::cluster_builder - An Master which performs cluster configuration

# Resources

* [mongodb](#mongodb)
* [mongodb_test](#mongodb_test)

## mongodb

### Actions

- install:  Default action.

### Attribute Parameters

- cluster_name:  Defaults to <code>nil</code>.
- configuration:  Defaults to <code>{}</code>.
- type:  Defaults to <code>:mongod</code>.

## mongodb_test

### Actions

- test:  Default action.

# License and Maintainer

Copyright: Yauhen Artsiukhou

Standard MIT License

Maintainer: Yauhen Artsiukhou <jsirex@gmail.com>
