include_recipe "zabbix_integration::pipe"
zabbix_monitor 'hbase' do
  gems %w[crack]
end
