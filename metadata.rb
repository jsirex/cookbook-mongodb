name             "mongodb"
maintainer       "Yauhen Artsiukhou"
maintainer_email "yauhen_artsiukhou@epam.com"
license          "EPAM"
description      "Installs/Configures mongodb"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.0"
depends          "apt"
depends          "iptables"
depends          "build-essential"

#supports         "ubuntu"
supports         "debian"

recipe "mongodb", "Installs default mongodb package without startup"
recipe "mongodb::single", "Installs mongodb as standalone server"
recipe "mongodb::config", "Installs mongodb as config server"
recipe "mongodb::route", "Installs mongodb as mongos router"
recipe "mongodb::shard", "Installs mongodb as shard"
recipe "mongodb::firewall", "Enables firewall on all mongos' ports"
recipe "mongodb::cluster_build", "An Master which performs cluster configuration"


