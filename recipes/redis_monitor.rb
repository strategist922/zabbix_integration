include_recipe "zabbix_integration::pipe"
zabbix_monitor 'redis' do
  gems %w[redis SystemTimer]
end
