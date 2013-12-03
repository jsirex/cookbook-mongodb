Vagrant.require_plugin "vagrant-chef-zero"
Vagrant.require_plugin "vagrant-berkshelf"
Vagrant.require_plugin "vagrant-omnibus"

Vagrant.configure("2") do |config|

  config.vm.box = "debian-7.1.0-64"
  config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_debian-7.1.0_provisionerless.box"
  config.vm.hostname = "mongodb"
  config.vm.network :public_network, :use_dhcp_assigned_default_route => false
  
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.chef_zero.enabled = true
  config.berkshelf.enabled = true
  config.omnibus.chef_version = "11.4.4"

  config.vm.provision :shell, :inline => %Q{
echo "Hacking MongoDB Package installation (fast download)."
test -e /var/cache/apt/archives/mongodb-10gen_2.4.8_amd64.deb ||
sudo wget --quiet --no-check-certificate --directory-prefix=/var/cache/apt/archives "https://evbyminsd5915.minsk.epam.com/docs/mongodb/mongodb-10gen_2.4.8_amd64.deb"
}
  # Single instance
  config.vm.define :single do |srv|
    srv.vm.hostname = "mongodb-single"

    srv.vm.provision :chef_client do |chef|
      chef.json = {
        'mongodb' => {
          'defaults' => {
            'service' => {
              'data_dir_prefix' => '/tmp/db'
            },
            'single' => {
              'smallfiles' => true
            }
          },         
          'singles' => {
            'mongodb-single' => {
              'opts' => {
                'logpath' => "/tmp/testlog",
                'port' => 30000
              }
            }
          }
        }
      }

      chef.run_list = [
        "recipe[mongodb::single]"
      ]
    end
  end

  # Shard 000 Replica Set
  config.vm.define :sh000 do |srv|
    srv.vm.hostname = "mongodb-shard-000"

    srv.vm.provision :chef_client do |chef|
      chef.json = {
        'mongodb' => {
          'shards' => {
            'shard000' => {
              'mongodb-sh000-1' => {
                'opts' => {
                  'smallfiles' => true,
                  'oplogSize' => 512,
                  'port' => 30000
                }
              },
              'mongodb-sh000-2' => {
                'opts' => {
                  'smallfiles' => true,
                  'oplogSize' => 512,
                  'port' => 33000
                }
              }
            },
            'shard001' => {
              'mongodb-sh001-arbiter' => {
                'arbiter' => true,
                'opts' => {
                  'port' => 20017
                }
              }
            }
          }
        }
      }

      chef.run_list = [
        "recipe[mongodb::shard]"
      ]
    end
  end

  # Shard 001 Replica Set
  config.vm.define :sh001 do |srv|
    srv.vm.hostname = "mongodb-shard-001"

    srv.vm.provision :chef_client do |chef|
      chef.json = {
        'mongodb' => {
          'shards' => {
            'shard001' => {
              'mongodb-sh001-1' => {
                'opts' => {
                  'smallfiles' => true,
                  'oplogSize' => 512,
                  'port' => 30000
                }
              },
              'mongodb-sh001-2' => {
                'opts' => {
                  'smallfiles' => true,
                  'oplogSize' => 512,
                  'port' => 33000
                }
              }
            },
            'shard000' => {
              'mongodb-sh000-arbiter' => {
                'arbiter' => true,
                'opts' => {
                  'port' => 20017
                }
              }
            }
          }
        }
      }

      chef.run_list = [
        "recipe[mongodb::shard]"
      ]
    end
  end

  # Configs and router
  config.vm.define :cfg do |srv|
    srv.vm.hostname = "mongodb-config"

    srv.vm.provision :chef_client do |chef|
      chef.json = {
        'mongodb' => {
          'configs' => {
            'mongodb-cfg-1' => {
              'opts' => {
                'smallfiles' => true,
                'oplogSize' => 512,
                'port' => 29017
              }
            },
            'mongodb-cfg-2' => {
              'opts' => {
                'smallfiles' => true,
                'oplogSize' => 512,
                'port' => 31017
              }
            },
            'mongodb-cfg-3' => {
              'opts' => {
                'smallfiles' => true,
                'oplogSize' => 512,
                'port' => 33017
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

      chef.run_list = [
        "recipe[mongodb::config]",
        "recipe[mongodb::router]",
        "recipe[mongodb::cluster_builder]"
      ]
    end
  end

end

