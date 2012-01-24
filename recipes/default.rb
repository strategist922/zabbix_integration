%w[rubix configliere].each { |name| gem_package(name) }

bash "create /dev/zabbix pipe" do
  code "sudo mkfifo /dev/zabbix && chown zabbix:admin /dev/zabbix && chmod 666 /dev/zabbix"
  not_if { File.exist?('/dev/zabbix') }
end

zabbix_server_ip = default_zabbix_server_ip
runit_service "zabbix_pipe" do
  options :server => zabbix_server_ip
end

announce(:zabbix, :pipe, :logs => { :pipe => '/etc/sv/zabbix_pipe/log/main/current' }, :daemons => { :pipe => 'zabbix_pipe' })
