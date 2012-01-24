include_recipe "zabbix_integration::default"
zabbix_monitor 'redis' do
  gems %w[redis SystemTimer]
end
