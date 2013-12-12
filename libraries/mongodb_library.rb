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

  # In mongo server connection is tcp endpoint in format "host:port"
  def self.server_available?(server)
    require 'rubygems'
    require 'mongo'
    return false unless server
    host, port = server.split(':')

    begin
      connection = ::Mongo::MongoClient.new(host, port, :slave_ok => true, :op_timeout => 5)
    rescue
      return false
    ensure
      connection.close if connection && connection.active?
    end

    true
  end

  # @return replicaset status in [:ok, :conf, :reconf]
  def self.check_replicaset_status(name, members)
    require 'rubygems'
    require 'mongo'
    
    begin
      connection = ::Mongo::MongoReplicaSetClient.new(members.map{|x| x['host']}, :read => :secondary_preferred)      
      config = connection['local']['system']['replset'].find_one({"_id" => name})
      
      config_member_hosts = config['members'].map {|m| m['host']}.sort
      member_hosts = members.map{|x| x['host']}.sort
     
      return member_hosts == config_member_hosts ? :ok : :reconf      
    rescue ::Mongo::ConnectionFailure => e
      return :conf
    ensure
      connection.close if connection && connection.active?
    end
  end
  
  def self.member_can_become_primary?(member)
    member['arbiterOnly'] != true && member['priority'] != 0 && member['hidden'] != true    
  end
  
  def self.configure_replicaset(cluster_name, repl_name, members)
    require 'rubygems'
    require 'mongo'
    
    members.sort!{|x,y| x['host'] <=> y['host']}
    members.each_index do |index|
      members[index]['_id'] = index      
    end
    
    # find first primary supported member
    index = members.index do |member|
      self.server_available?(member['host']) && self.member_can_become_primary?(member)
    end
    
    unless index 
      Chef::Log.warn("[#{cluster_name}] No servers available for #{repl_name}. Give up.")
      return
    end
    
    master = members[index]    
    
    cmd = BSON::OrderedHash.new
    cmd['replSetInitiate'] = {
      "_id" => repl_name,
      "members" => members
    }
        
    begin
      # connect to the first non-arbiter
      host, port = master['host'].split(':')
      connection = ::Mongo::MongoClient.new(host, port, :op_timeout => 5)
    rescue ::Mongo::MongoRubyError => e
      Chef::Log.warn("[#{cluster_name}] Could not connect to database: #{e}")
      return
    end

    begin
      admin = connection['admin']
      result = admin.command(cmd, :check_response => false)
    rescue ::Mongo::OperationTimeout
      Chef::Log.info("[#{cluster_name}] Started configuring the #{repl_name} replicaset, this will take some time, another run should run smoothly.")
      return
    ensure
      connection.close if connection && connection.active?
    end

    if result.fetch("ok", nil) == 1
      Chef::Log.info("[#{cluster_name}] Replication #{repl_name} configured succesfully!")
    elsif result.fetch("errmsg", nil) == "already initialized" or result.fetch("errmsg", nil) =~ /already initiated/
      Chef::Log.info("[#{cluster_name}] Replication #{repl_name} already initialized")
    elsif !result.fetch("errmsg", nil).nil?
      Chef::Log.error("[#{cluster_name}] Failed to configure #{repl_name} replicaset, reason: #{result.inspect}")
    end
  end

  def self.reconfigure_replicaset(cluster_name, repl_name, members)
    require 'rubygems'
    require 'mongo'
    
    members.sort!{|x,y| x['host'] <=> y['host']}
    
    connection = nil
    begin
      connection = ::Mongo::MongoReplicaSetClient.new(members.map{|x| x['host']}, :read => :primary)
    rescue ::Mongo::ConnectionFailure => e
      Chef::Log.warn("[#{cluster_name}] Could not connect to replicaset #{repl_name}: #{members.inspect}")
      return
    end

    config = connection['local']['system']['replset'].find_one({"_id" => repl_name})
    Chef::Log.debug("[#{cluster_name}] Detected old configuration: #{config.inspect}")
    if config

      config['version'] = config['version'] + 1
      next_index = config['members'].map{|m| m['_id']}.max + 1

      # Get new_servers list
      new_servers = members.dup
      config['members'].each do |c_member|
        new_servers.delete_if {|m| m['host'] == c_member['host']}
      end
      
      #remove from config servers, which actually removed (not in servers)
      config['members'].delete_if do |c_member|
        members.index{|x| x['host'] == c_member['host']}.nil?
      end

      new_servers.each do |new_server|
        new_server['_id'] = next_index
        config['members'] << new_server
        next_index +=1
      end
      
      Chef::Log.debug("[#{cluster_name}] New configuration: #{config.inspect}")

      cmd = BSON::OrderedHash.new
      cmd['replSetReconfig'] = config

      begin
        rs_admin = connection['admin']
        result = rs_admin.command(cmd, :check_response => true)
        Chef::Log.debug("[#{cluster_name}] #{repl_name} reconfiguration respone: #{result.inspect}")
      rescue
       Chef::Log.info("[#{cluster_name}] #{repl_name} reconfiguration scheduled.")
      end
    else
      Chef::Log.warn("[#{cluster_name}] Unable to get replicaset config for #{repl_name}: #{members.inspect}. Strange")
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
  # String router (host:port)
  # String shard_name
  # Array members (host:port)
  def self.add_shard(cluster_name, router, shard_name, hosts)
    # lazy require, to move loading this modules to runtime of the cookbook
    require 'rubygems'
    require 'mongo'
    
    result = nil
    connection = nil
    begin
      host, port = router.split(':')
      connection = ::Mongo::MongoClient.new(host, port, :op_timeout => 5)
      admin = connection['admin']
      cmd = BSON::OrderedHash.new
      cmd['addShard'] = "#{shard_name}/#{hosts.join(',')}"
      result = admin.command(cmd, :check_response => false)
    rescue ::Mongo::OperationTimeout
      Chef::Log.info("[#{cluster_name}] Adding shard '#{shard_name}' timed out. Will try again on next chef run")    
    end
    
    unless result.nil?
      if result.fetch("ok", nil) == 1
        Chef::Log.info("[#{cluster_name}] Shard #{shard_name} has been added")
      elsif result.fetch('errmsg', nil) =~ /duplicate key/
        Chef::Log.info("[#{cluster_name}] Shard #{shard_name} already added (duplicate key error)")
      else
        Chef::Log.warn("[#{cluster_name}] Adding #{shard_name} returned: #{result.fetch('errmsg', nil)}")
      end  
    end   

    connection.close if connection && connection.active?
  end # def self.add_shard

end

