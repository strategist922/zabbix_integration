zabbix_server_ip = default_zabbix_server_ip

# Iterate over ever component with a port aspect...
components_with(:ports).each do |component|

  # Zabbix already tracks the Zabbix server & agent.
  next if component.sys.to_s == 'zabbix' && %w[server agent].include?(component.subsys.to_s)

  # ... and over each port aspect for the component...
  component.ports.each_pair do |aspect_name, aspect_props|

    # Now we figure out the actual ports.
    aspect_props = { :port => aspect_props } unless aspect_props.is_a?(Hash)

    # The item key is used to define what the zabbix Item measures
    # as well as refer to connect a Trigger to an Item.
    #
    # For Item key syntax see
    # 
    #   http://www.zabbix.com/documentation/2.0/manual/config/items/itemtypes/zabbix_agent/keys
    #
    # This item's key returns the response time (in seconds or '0' if
    # down) of the specified protocol.
    port     = aspect_props[:port].to_s if aspect_props[:port]
    protocol = aspect_props[:protocol] || 'tcp'
    item_key = [protocol + '_perf', port].join(',')
    item     = "#{node.node_name}:#{item_key}"

    # Create an Item in Zabbix using the item key.
    zabbix_item "Performance of port #{port} for #{component.fullname}" do
      server       zabbix_server_ip
      host         node.node_name
      applications ['Ports']
      key          item_key
      type         :simple       # 'simple' means the check is done by the Zabbix server
      value_type   :float
      units        's'
    end

    # Create a Trigger on this item that fires when accessing the port
    # fails too often.
    #
    # For Trigger expression syntax see
    # 
    #   http://www.zabbix.com/documentation/2.0/manual/config/triggers/expression
    # 
    window     = aspect_props[:availability_window] || node.zabbix_integration.ports.availability.window
    failures   = aspect_props[:failures]            || node.zabbix_integration.ports.availability.failures
    trigger    = "{#{item}.count(#{window},0)}>#{failures}"
    zabbix_trigger "Too many failures on port #{port} for #{component.fullname}" do
      server     zabbix_server_ip
      host       node.node_name
      expression trigger
      priority   aspect_props[:availability_priority] || node.zabbix_integration.ports.availability.priority
      comments   "Port #{port} is used on #{node.node_name} to implement #{component.fullname}.\n\nIt failed to accept a connection #{failures} times within the last #{window} seconds."
    end

    # Create a Trigger on this item that fires when the response time
    # of the port becomes too high.
    window        = aspect_props[:response_time_window] || node.zabbix_integration.ports.response_time.window
    response_time = aspect_props[:response_time] || node.zabbix_integration.ports.response_time.average
    trigger       = "{#{item}.avg(#{window})}>#{response_time}"
    zabbix_trigger "Response time too high on port #{port} for #{component.fullname}" do
      server     zabbix_server_ip
      host       node.node_name
      expression trigger
      priority   aspect_props[:response_time_priority] || node.zabbix_integration.ports.response_time.priority
      comments   "Port #{port} is used on #{node.node_name} to implement #{component.fullname}.\n\nIts response time over the last #{window} seconds has risen to #{response_time} seconds."
    end
    
  end
end
