default_action :install

attribute :cluster, :kind_of => String, :default => nil
attribute :repl_set, :kind_of => String, :default => nil
attribute :configuration, :kind_of => Hash, :default => {}
attribute :type, :equal_to => [:config, :router, :shard, :single], :default => :shard

