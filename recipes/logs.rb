zabbix_server_ip = default_zabbix_server_ip

# Iterate over ever component with a log aspect...
components_with(:logs).each do |component|

  # ... and over each log aspect for the component...
  component.logs.each_pair do |aspect_name, aspect_props|

    # Now we figure out the paths to the actual log files that will
    # need to be rotated by lograted for this aspect.
    aspect_props = { :path => aspect_props } unless aspect_props.is_a?(Hash)

    # Skip if we need to
    next if aspect_props[:monitor] == false
    
    log_path = aspect_props[:path]
    case
    when !File.exist?(log_path)
      Chef::Log.warn("Could not find a log file/directory at #{log_path} to monitor, skipping...")
      next
    when File.directory?(log_path)
      paths = Dir[File.join(log_path, '*')]
    else
      paths = [log_path]
    end

    # For each path this log aspect has...
    paths.each do |path|

      # The item key is used to define what the zabbix Item measures
      # as well as refer to connect a Trigger to an Item.
      #
      # For Item key syntax see
      # 
      #   http://www.zabbix.com/documentation/2.0/manual/config/items/itemtypes/zabbix_agent/keys
      #
      # This item's key returns the size of the file at +path+ in
      # bytes.
      item_key = "vfs.file.size[#{path}]"
      item     = "#{node.node_name}:#{item_key}"

      # Create an Item in Zabbix using the item key.
      zabbix_item "Size of #{File.basename(path)} for #{component.fullname}" do
        server       zabbix_server_ip
        host         node.node_name
        applications ['Logs']
        key          item_key
        type         :zabbix     # The item can be measured by the local Zabbix agent.
        value_type   :unsigned_int
        units        'b'
      end

      # Create and enable a Trigger on this item that fires when the
      # path's size exceeds the threshold
      #
      # For Trigger expression syntax see
      # 
      #   http://www.zabbix.com/documentation/2.0/manual/config/triggers/expression
      # 
      max_size   = (aspect_props[:max_size] || node.zabbix_integration.logs.file_size.max_size)
      trigger    = "{#{item}.last(0)}>#{max_size.to_i * 1_048_576}"
      zabbix_trigger "#{component.fullname}'s log at #{path} has grown too large" do
        server     zabbix_server_ip
        host       node.node_name
        expression trigger
        priority   aspect_props[:priority] || node.zabbix_integration.logs.file_size.priority
        comments   "The file #{path} is logged to by #{component.fullname} on #{node.node_name}.\n\nIt has grown to #{max_size} MB in size."
      end
    end
  end
end
