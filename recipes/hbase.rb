include_recipe "zabbix_integration::default"
zabbix_monitor 'hbase' do
  gems %w[crack]
end
