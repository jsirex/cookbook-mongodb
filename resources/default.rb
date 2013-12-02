default_action :install

attribute :cluster_name, :kind_of => String, :default => nil
attribute :configuration, :kind_of => Hash, :default => {}
attribute :binary, :equal_to => [:mongos, :mongod], default => :mongod

