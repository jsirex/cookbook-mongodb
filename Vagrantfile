Vagrant.require_plugin "vagrant-chef-zero"
Vagrant.require_plugin "vagrant-berkshelf"
Vagrant.require_plugin "vagrant-omnibus"

Vagrant.configure("2") do |config|

  config.vm.box = "debian-7.1.0-64"
  config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_debian-7.1.0_provisionerless.box"

  config.vm.hostname = "mongodb"
  config.vm.network :public_network, :use_dhcp_assigned_default_route => false

  config.chef_zero.enabled = true

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.berkshelf.enabled = true
  config.omnibus.chef_version = "11.4.4"

  config.vm.provision :shell, :inline => %Q{
echo "Hacking MongoDB Package installation."
test -e /var/cache/apt/archives/mongodb-10gen_2.4.5_amd64.deb ||
sudo wget --quiet --no-check-certificate --directory-prefix=/var/cache/apt/archives "https://evbyminsd5915.minsk.epam.com/mongodb/mongodb-10gen_2.4.8_amd64.deb"
}

  config.vm.define :single do |single|
    single.vm.hostname = "mongodb-single"
    
    single.vm.provision :chef_client do |chef|
      chef.json = {
        'mongodb' => {
          'singles' => {
            'mongo-single' => {
              'opts' => {
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

end

