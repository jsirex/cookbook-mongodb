Description
===========

Add apt repository and install mongodb-10gen. 

## Platform

* debian

Currently there is only debian is supported. But, if you want to add support for your OS, just reimplemnt installation process (extend `default` recipe)


Requirements
============

- OpscodeCookbook[apt]
- OpscodeCookbook[firewall]
- OpscodeCookbook[build-essentials]


Attributes
==========

['mongodb']['package'] - Which package name use to install mongo

['mongodb']['version'] - Explicit version *must* be provided for the each cluster. No automatic upgrades are allowed. It is complecated process not always compatible with aplication
 
['mongodb']['cluster_name'] - All mongo instances belongs to a cluster

['mongodb']['defaults'] - Default values for all instances

['mongodb']['defaults']['service'] - Service specific values, like `install_prefix`, `log_prefix`, `rs_member_conf` for replicaset members

['mongodb']['defaults']['service']['rs_member_conf'] - For replicaset. When replicaset will be initialized this configuration will be applied on replicaset member. This is hash. Sample values:
* `node.default['mongodb']['defaults']['service']['rs_member_conf']['hidden'] = true`
* `node.default['mongodb']['defaults']['service']['rs_member_conf']['arbiterOnly'] = true`
* `node.default['mongodb']['defaults']['service']['rs_member_conf']['priority'] = 0`
Look at mongodb documentation for more information

['mongodb']['defaults']['opts'] - Default mongo config options (key = value) (Located in mongodb configuration file)

['mongodb']['defaults']['config'] - Default values for all mongodb config instances

['mongodb']['defaults']['routers'] - Default values for all mongodb mongos instances

['mongodb']['defaults']['shard'] - Default values for all mongodb shards instances

Attribute shortcuts
-------------------

`service_attributes` is attributes defined in `node['mongodb']['<shards|configs|routers|singles>']['<your_service>']`.

Here is list:
* `data_dir_prefix` - where to keep database files? Directory with the `service_name` will be created here. Default '/var/lib'
* `log_file_prefix` - where to keep log files. Default '/var/log/mongodb'
* `config_file_prefix` - where to keep configuration files. Default '/etc/mongodb'
* `pid_file_prefix` - where to keep pid file. Default '/var/run'
* `use_fqdn` - when building replicaset use FQDN or IPADDRESS? Default false
* `arbiter` - shortcut for defining an arbiter. Set to `true`. Default not set
* `rs_member_conf` - custom configuration for replicaset member. Default not set  

Runtime calculated attributes
-----------------------------

* `default['mongodb']['shards'][shard_name][service_name]['config_file']`   
* `default['mongodb']['shards'][shard_name][service_name]['opts']['logpath']` 
* `default['mongodb']['shards'][shard_name][service_name]['opts']['pidfilepath']` 
* `default['mongodb']['shards'][shard_name][service_name]['opts']['dbpath']`
* `default['mongodb']['shards'][shard_name][service_name]['opts']['replSet']`
* `default['mongodb']['shards'][shard_name][service_name]['rs_member_conf']['host']`


Usage
=====

### Available recipes

#### default

- Add 10gen official repository and install newer stable mongodb.
- **disable** autostart when install or serverboot.
- Dynamicaly append node attributes

Default recipe used whenever mongod or mongos is going to install (will be automatically included)

#### single

- Installs standalone mongodb instance

#### config

- setup mongodb config node[s]. Required exactly 3 instances of config server.

#### router

- setup mongodb router(mongos) node[s].

#### shard

- setup mongodb shard/repl_set node[s]

#### cluster_builder

- Recommended only one per cluster
- Detects all replica sets and (re-)configure them
- Detects all shards and add new if found (Shards never removed automatically)

Installing multiple instances using attributes
==============================================

You can install on single node as many configs, routers, shards/replicasets, singles as you want. Each entity can have it's own configuration.
To ask cookbook install your things define attributes in corresponding section:

```ruby
node.set['mongodb']['shards']['shard_name']['shard-service-name-1'] = opts_hash_1
node.set['mongodb']['shards']['shard_name']['shard-service-name-2'] = opts_hash_2
node.set['mongodb']['configs']['config-service-name'] = opts_hash_3
```

This code defines only one shard with name `shard_name`. Services will have names `shard-service-name-1` and `shard-service-name-2` respectively.
Also this code defines one config `config-service-name`.

`opts_hash_N` is pseudo-code - this is any attributes you may want to define/override for the service.

Cookbook:

* takes `node['mongodb']['defaults']['service']` as default attributes for all services. 
Attributes `node['mongodb']['<shards|configs|routers|singles>']['<your_service>']` with higher priority (custom defined) will not been overwritten. 
* takes `node['mongodb']['defaults']['opts']`, merges with service specific default options in `node['mongodb']['defaults']['<config|router|shard|single>']`
* merged default attributes from previous step are merged with service defined in `node['mongodb']['<shards|configs|routers|singles>']['<your_service>']['opts']` 

Investigate `_configuration` helper recipe if you have questions.


Examples
========

See usage of the mongodb cookbook in `Vagrantfile`:

* `vagrant up single` - brings up standalone version of mongodb
* `vagrant up sh000 sh001 cfg` - brings up sharded replicated mongodb cluster

Defining hidden delayed replicaset member in shard_000 can be done like this:

```ruby
node.set['mongodb']['shards']['shard_000']['mongodb-sh000-hidden-delayed]['rs_member_conf']['hidden'] = true
node.set['mongodb']['shards']['shard_000']['mongodb-sh000-hidden-delayed]['rs_member_conf']['priority'] = 0
node.set['mongodb']['shards']['shard_000']['mongodb-sh000-hidden-delayed]['rs_member_conf']['slaveDelay'] = 3600
# Customizing options
node.set['mongodb']['shards']['shard_000']['mongodb-sh000-hidden-delayed]['opts']['port'] = 9000
node.set['mongodb']['shards']['shard_000']['mongodb-sh000-hidden-delayed]['opts']['smallfiles'] = true
# Place data files in different directory
node.set['mongodb']['shards']['shard_000']['mongodb-sh000-hidden-delayed]['data_dir_prefix'] = '/data/mongodb'
```





