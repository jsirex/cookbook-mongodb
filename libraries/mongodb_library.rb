require 'json'

class Chef::Recipe::MongoDB

  def self.each_single(node)
    singles = node['mongodb']['singles'] || {} rescue {}
    singles.each_pair {|name, opts| yield(name, opts)}
  end

  def self.each_shard(node)
    shards = node['mongodb']['shards'].keys rescue []
    shards.each {|shard_name| yield shard_name}
  end

  def self.each_shard_server(node, shard_name)
    shard_servers = node['mongodb']['shards'][shard_name] || {} rescue {}
    shard_servers.each_pair {|name, opts| yield(name, opts)}
  end

  def self.each_config(node)
    configs = node['mongodb']['configs'] || {} rescue {}
    configs.each_pair {|name, opts| yield(name, opts)}
  end

  def self.each_router(node)
    routers = node['mongodb']['routers']  || {} rescue {}
    routers.each_pair {|name, opts| yield(name, opts)}
  end

  def self.server_available?(server)
    require 'rubygems'
    require 'mongo'

    return false unless server
    host, port = server.split(':')
    connection = nil
    begin
      connection = ::Mongo::MongoClient.new(host, port, :slave_ok => true, :op_timeout => 5)
    rescue
    connection.close if connection && connection.active?
    return false
    end
    connection.close if connection && connection.active?
    true
  end

  # @return replicaset status in [:ok, :conf, :reconf]
  def self.check_replicaset_status(name, servers)
    require 'rubygems'
    require 'mongo'

    connection = nil
    begin
      connection = ::Mongo::MongoReplicaSetClient.new(servers.map{|x| "#{x[:host]}:#{x[:port]}"}, :read => :secondary_preferred)
    rescue ::Mongo::ConnectionFailure => e
    # replica not configured
      return :conf
    end
    config = connection['local']['system']['replset'].find_one({"_id" => name})
    replica_hosts = config['members'].map {|m| m['host']}.sort
    connection.close if connection && connection.active?
    if replica_hosts == servers.map{|x| "#{x[:host]}:#{x[:port]}"}
      return :ok
    else
      return :reconf
    end
  end

  def self.configure_replicaset(cluster_name, repl_name, servers)
    # lazy require, to move loading this modules to runtime of the cookbook
    require 'rubygems'
    require 'mongo'

    rs_members = []
    servers.sort{|x,y| "#{x[:host]}:#{x[:port]}" <=> "#{y[:host]}:#{y[:port]}"}.each_with_index do |server, index|
      rs_members << {"_id" => index, "host" => "#{server[:host]}:#{server[:port]}", "arbiterOnly" => server[:arbiter] ? true : false}
    end

    cmd = BSON::OrderedHash.new
    cmd['replSetInitiate'] = {
      "_id" => repl_name,
      "members" => rs_members
    }

    connection = nil
    server = nil
    servers.each do |srv|
      if self.server_available?("#{srv[:host]}:#{srv[:port]}")
        server = "#{srv[:host]}:#{srv[:port]}"
      break
      end
    end
    Chef::Log.warn("[#{cluster_name}] No servers available for #{repl_name}. Give up.") unless server

    begin
      host, port = server.split(':')
      # connect to the first non-arbiter
      connection = ::Mongo::MongoClient.new(host, port, :op_timeout => 5, :slave_ok => true)
    rescue
      Chef::Log.warn("[#{cluster_name}] Could not connect to database: '#{host}:#{port}'")
    return
    end

    raise "Lost db connection" if connection.nil?
    result = nil
    begin
      admin = connection['admin']
      result = admin.command(cmd, :check_response => false)
    rescue ::Mongo::OperationTimeout
      Chef::Log.info("[#{cluster_name}] Started configuring the #{repl_name} replicaset, this will take some time, another run should run smoothly.")
    connection.close if connection.active?
    return
    end

    if result.fetch("ok", nil) == 1
      Chef::Log.info("[#{cluster_name}] Replication #{repl_name} configured succesfully!")
    elsif result.fetch("errmsg", nil) == "already initialized" or result.fetch("errmsg", nil) =~ /already initiated/
      Chef::Log.info("[#{cluster_name}] Replication #{repl_name} already initialized")
    elsif !result.fetch("errmsg", nil).nil?
      Chef::Log.error("[#{cluster_name}] Failed to configure #{repl_name} replicaset, reason: #{result.inspect}")
    end
    connection.close if connection && connection.active?
  end

  def self.reconfigure_replicaset(cluster_name, repl_name, servers)
    require 'rubygems'
    require 'mongo'
    connection = nil
    begin
      connection = ::Mongo::MongoReplicaSetClient.new(servers.map{|x| "#{x[:host]}:#{x[:port]}"}, :read => :primary)
    rescue ::Mongo::ConnectionFailure => e
      Chef::Log.warn("[#{cluster_name}] Could not connect to replicaset #{repl_name}: #{servers.inspect}")
    end

    config = connection['local']['system']['replset'].find_one({"_id" => repl_name})
    Chef::Log.info(config.inspect)
    if config
      # Get new_servers list
      new_servers = servers.sort{|x,y| "#{x[:host]}:#{x[:port]}" <=> "#{y[:host]}:#{y[:port]}"}
      config['members'].each do |c_member|
        new_servers.delete_if {|m| "#{m['host']}:#{m['port']}" == c_member['host']}
      end
      Chef::Log.info(config.inspect)
      Chef::Log.info(servers.inspect)
      #remove from config servers, which actually removed (not in servers)
      config['members'].delete_if do |c_member|
        servers.index{|x| "#{x[:host]}:#{x[:port]}" == c_member['host']}.nil?
      end

      Chef::Log.info(config.inspect)

      version = config['version']
      next_index = config['members'].map{|m| m['_id']}.max + 1
      config['version'] = version + 1
      new_servers.each do |new_server|
        config['members'] << {'_id' => next_index, 'host' => "#{new_server[:host]}:#{new_server[:port]}"}
        next_index +=1
      end

      Chef::Log.info("Result config: #{config.inspect}")
      cmd = BSON::OrderedHash.new
      cmd['replSetReconfig'] = config

      begin
        rs_admin = connection['admin']
        result = rs_admin.command(cmd, :check_response => true)
      #rescue
      #  Chef::Log.info("[#{cluster_name}] #{repl_name} reconfiguration scheduled.")
      end
    else
      Chef::Log.warn("[#{cluster_name}] Unable to get replicaset config for #{repl_name}: #{servers.inspect}. Strange")
    end
    connection.close if connection && connection.active?
  end

  def self.get_existing_shards(cluter_name, router)
    require 'rubygems'
    require 'mongo'
    connection = nil
    begin
      host, port = router.split(':')
      connection = ::Mongo::MongoClient.new(host, port, :op_timeout => 5)
      cmd = BSON::OrderedHash.new
      cmd['listShards'] = 1
      admin = connection['admin']
      result = admin.command(cmd, :check_response => false)
    rescue Exception => e
      Chef::Log.warn("#{cluter_name} Listing existing shards on #{router} failed: : #{e}")
    ensure
    connection.close if connection && connection.active?
    end
    if result['ok'] == 1
      return result['shards'].map {|sh| sh['_id']}
    else
      Chef::Log.warn("[#{cluter_name}] #{result['errmsg']}")
    return []
    end
  end

  # String cluster_name
  # String router
  # String shard_name
  # Array servers
  def self.add_shard(cluster_name, router, shard_name, servers)
    # lazy require, to move loading this modules to runtime of the cookbook
    require 'rubygems'
    require 'mongo'

    connection = nil
    begin
      host, port = router.split(':')
      connection = ::Mongo::MongoClient.new(host, port, :op_timeout => 5)
      admin = connection['admin']
      cmd = BSON::OrderedHash.new
      cmd['addShard'] = "#{shard_name}/#{servers.join(',')}"
      result = admin.command(cmd, :check_response => false)
    rescue ::Mongo::OperationTimeout
      Chef::Log.info("[#{cluster_name}] Adding shard '#{shard_name}' timed out. Will try again on next chef run")
    rescue Exception => e
    # ignoring any other exceptions
    end

    if result.fetch("ok", nil) == 1
      Chef::Log.info("[#{cluster_name}] Shard #{shard_name} has been added")
    elsif result.fetch('errmsg', nil) =~ /duplicate key/
      Chef::Log.info("[#{cluster_name}] Shard #{shard_name} already added (duplicate key error)")
    else
      Chef::Log.warn("[#{cluster_name}] Adding #{shard_name} returned: #{result.fetch('errmsg', nil)}")
    end

    connection.close if connection && connection.active?
  end # def self.add_shard

end

