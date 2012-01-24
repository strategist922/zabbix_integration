include_recipe "zabbix_integration::default"
zabbix_monitor 'mongodb' do
  gems %w[mongo]
end
