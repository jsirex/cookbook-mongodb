require 'socket'

# Launch and provision two servers to build an elastic search cluster under debian
puts "[Vagrant] #{Vagrant::VERSION}"
puts "[Vagrant] MongoDB cookbook is used!"

# Including global config
node_sh1 = {
  'mongodb' => {
    'version' => '2.4.5',
    'cluster_name' => 'e3s',
    'shards' => {
      'sh1' => {
        'mongodb_1' => {
          'install_prefix' => '/data', # for test
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
          'port' => 36017
        }
      }
    }
  }
}

node_sh2 = {
  'mongodb' => {
    'version' => '2.4.5',
    'cluster_name' => 'e3s',
    'shards' => {
      'sh2' => {
        'mongodb_1' => {
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
        }
      }
    },
    'routers' => {
      'mongos' => {
        'opts' => {
          'port' => 36017
        }
      }
    }
  }
}
node_sh3 = {
  'mongodb' => {
    'version' => '2.4.5',
    'cluster_name' => 'e3s',
    'shards' => {
      'sh3' => {
        'mongodb_1' => {
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
        }
      }
    },
    'routers' => {
      'mongos' => {
        'opts' => {
          'port' => 36017
        }
      }
    }
  }
}

node_cfg1 = {
  'mongodb' => {
    'version' => '2.4.5',
    'cluster_name' => 'e3s',
    'configs' => {
      'mongodb_config_1' => {
        'opts' => {
          'port' => 27019,
          'smallfiles' => true,
          'oplogSize' => 512
        }
      },
      'mongodb_config_2' => {
        'opts' => {
          'port' => 30019,
          'smallfiles' => true,
          'oplogSize' => 512
        }
      },
      'mongodb_config_3' => {
        'opts' => {
          'port' => 33019,
          'smallfiles' => true,
          'oplogSize' => 512
        }
      }
    },
    'routers' => {
      'mongos' => {
        'opts' => {
          'port' => 36017
        }
      },
      'mongos2' => {
        'opts' => {
          'port' => 27017
        }
      }
    }
  }
}

Vagrant.configure("2") do |config|

  config.vm.provision :shell, :inline => %Q{
    echo "Hacking MongoDB Package installation."
    test -e /var/cache/apt/archives/mongodb-10gen_2.4.5_amd64.deb ||
    sudo wget --quiet --no-check-certificate --directory-prefix=/var/cache/apt/archives "https://evbyminsd5915.minsk.epam.com/mongodb/mongodb-10gen_2.4.5_amd64.deb" 
  }

  config.vm.define :sh1 do |sh1|
    sh1.vm.hostname = Socket.gethostname + "SH1"

    sh1.vm.provision :chef_client do |chef|
      chef.chef_server_url = "https://evbyminsd5915.minsk.epam.com"

      chef.validation_client_name = "vagrant"
      chef.validation_key_path = File.dirname(File.expand_path(__FILE__)) + '/../../.chef/vagrant-validation.pem'


      chef.add_recipe 'iptables'
      chef.add_recipe 'iptables::ssh'
      chef.add_recipe 'mongodb::limits'
      chef.add_recipe 'mongodb::firewall'
      chef.add_recipe 'mongodb'
      chef.add_recipe 'mongodb::shard'
      chef.add_recipe 'mongodb::router'
      chef.json = node_sh1

    end
  end

  config.vm.define :sh2 do |sh2|
    sh2.vm.hostname = Socket.gethostname + "SH2"

    sh2.vm.provision :chef_client do |chef|
      chef.chef_server_url = "https://evbyminsd5915.minsk.epam.com"

      chef.validation_client_name = "vagrant"
      chef.validation_key_path = File.dirname(File.expand_path(__FILE__)) + '/../../.chef/vagrant-validation.pem'

      chef.add_recipe 'iptables'
      chef.add_recipe 'iptables::ssh'
      chef.add_recipe 'mongodb::firewall'
      chef.add_recipe 'mongodb'
      chef.add_recipe 'mongodb::shard'
      chef.add_recipe 'mongodb::router'
      chef.json = node_sh2

    end
  end

  config.vm.define :sh3 do |sh3|
    sh3.vm.hostname = Socket.gethostname + "SH3"

    sh3.vm.provision :chef_client do |chef|
      chef.chef_server_url = "https://evbyminsd5915.minsk.epam.com"

      chef.validation_client_name = "vagrant"
      chef.validation_key_path = File.dirname(File.expand_path(__FILE__)) + '/../../.chef/vagrant-validation.pem'

      chef.add_recipe 'iptables'
      chef.add_recipe 'iptables::ssh'
      chef.add_recipe 'mongodb::firewall'
      chef.add_recipe 'mongodb'
      chef.add_recipe 'mongodb::shard'
      chef.add_recipe 'mongodb::router'
      chef.json = node_sh3

    end
  end

  config.vm.define :cfg1 do |cfg1|
    cfg1.vm.hostname = Socket.gethostname + "CFG1"

    cfg1.vm.provision :chef_client do |chef|
      chef.chef_server_url = "https://evbyminsd5915.minsk.epam.com"

      chef.validation_client_name = "vagrant"
      chef.validation_key_path = File.dirname(File.expand_path(__FILE__)) + '/../../.chef/vagrant-validation.pem'

      chef.add_recipe 'iptables'
      chef.add_recipe 'iptables::ssh'
      chef.add_recipe 'mongodb::firewall'
      chef.add_recipe 'mongodb'
      chef.add_recipe 'mongodb::config'
      chef.add_recipe 'mongodb::router'
      chef.add_recipe 'mongodb::cluster_builder'
      chef.json = node_cfg1

    end
  end
end
