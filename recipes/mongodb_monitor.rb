include_recipe "zabbix_integration::pipe"
zabbix_monitor 'mongodb' do
  gems %w[mongo]
end
