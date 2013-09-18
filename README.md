Description
===========

Add apt repository and install mongodb-10gen. 

## Platform

* ubuntu
* debian

### Tested on

* ubuntu 12.04(precise)
* debian 7.1(wheezy)

Requirements
============

- OpscodeCookbook[apt],OpscodeCookbook[firewall]


Attributes
==========

### ['mongodb']['package']

Which package name use to install mongo

### ['mongodb']['version']

Explicit version *must* be provided for the each cluster. No automatic upgrades are allowed. It is complecated process not always compatible with aplication. 

### ['mongodb']['cluster_name']

All mongo instances belongs to a cluster

### group ['mongodb']['defaults']

Default values for all instances

### group ['mongodb']['defaults']['service']

Service specific values

### group ['mongodb']['defaults']['opts']

Default mongo config options (key = value)

### group ['mongodb']['defaults']['config']

Default values for all mongodb config instances

### group ['mongodb']['defaults']['routers']

Default values for all mongodb mongos instances

### group ['mongodb']['defaults']['shard']

Default values for all mongodb shards instances


Usage
=====

### Available recipes

#### default

- Add 10gen official repository and install newer stable mongodb.
- **disable** autostart when install or serverboot.
- Dynamicaly append node attributes

Default recipe must be included whenever mongod or mongos is going to install

#### config

- setup mongodb config node[s].

#### router

- setup mongodb router(mongos) node[s].

#### shard

- setup mongodb shard/repl_set node[s]

#### cluster_builder

- Recommended only one per cluster
- Detects all replica sets and configure them
- Detects all shards and add new if found

Examples
========

Use `recipe[mongodb], recipe[mongodb::shard], recipe[mongodb:router]`


	node_attributes = {
	  'mongodb' => {
	    'version' => '2.4.5',
	    'cluster_name' => 'my_cluster',
	    'shards' => {
	      'sh1' => {
	        'mongodb_1' => {
	          'install_prefix' => '/data', # override default value
	          'opts' => {
	            'smallfiles' => true,
	            'oplogSize' => 512,
	            'port' => 30017
	          }
	        },
	        'mongodb_2' => {
	          'opts' => {
	            'smallfiles' => true,
	            'oplogSize' => 512,
	            'port' => 33017
	          }
	        },
	        'mongodb_3' => {
	          'opts' => {
	            'smallfiles' => true,
	            'oplogSize' => 512,
	            'port' => 39017
	          }
	        }
	      }
	    },
	    'routers' => {
	      'mongos' => {
	        'opts' => {
	          'port' => 27017
	        }
	      }
	    }
	  }
	} 




