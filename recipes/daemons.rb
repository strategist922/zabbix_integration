zabbix_server_ip = default_zabbix_server_ip

# Iterate over ever component with a daemon aspect...
components_with(:daemons).each do |component|

  # ... and over each daemon aspect for the component...
  component.daemons.each_pair do |aspect_name, aspect_props|
    aspect_props = { :name => aspect_props } unless aspect_props.is_a?(Hash)

    # Skip if we need to
    next if aspect_props[:monitor] == false
    
    # The item key is used to define what the zabbix Item measures
    # as well as refer to connect a Trigger to an Item.
    #
    # For Item key syntax see
    # 
    #   http://www.zabbix.com/documentation/2.0/manual/config/items/itemtypes/zabbix_agent/keys
    #
    # This item's key returns the number of processes with a given
    # name run by a given user with a given command line.
    name     = aspect_props[:name]
    user     = aspect_props[:user]
    state    = aspect_props[:state] || 'all'
    cmd      = aspect_props[:cmd]
    args     = [name,user,state,cmd].map(&:to_s).join(',')
    item_key = "proc.num[#{args}]"
    item     = "#{node.node_name}:#{item_key}"

    # Create an Item in Zabbix using the item key.
    zabbix_item "Number of #{name} daemons for #{component.fullname}" do
      server       zabbix_server_ip
      host         node.node_name
      applications ['Daemons']
      key          item_key
      type         :zabbix     # The item can be measured by the local Zabbix agent.
      value_type   :unsigned_int
    end

    # Create and enable a Trigger on this item that fires when the
    # number of processes is less than the threshold.
    #
    # For Trigger expression syntax see
    # 
    #   http://www.zabbix.com/documentation/2.0/manual/config/triggers/expression
    # 
    num_daemons = (aspect_props[:number] || 1)
    trigger     = "{#{item}.last(0)}<#{num_daemons}"
    zabbix_trigger "#{component.fullname} is not running #{name}" do
      server     zabbix_server_ip
      host       node.node_name
      expression trigger
      priority   aspect_props[:priority] || node.zabbix_integration.daemons.running.priority
      comments   "There are supposed to be at least #{num_daemons} #{name} daemon process(es) belonging to #{component.fullname} on #{node.node_name}."
    end
  end
end
