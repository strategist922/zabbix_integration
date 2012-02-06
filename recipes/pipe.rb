%w[rubix configliere].each { |name| gem_package(name) }

fifo = node.zabbix_integration.pipe
case
when File.exist?(fifo) && File.ftype(fifo) != 'fifo'
  Chef::Log.warn("A file exists at #{fifo} but it's not a FIFO, it's a #{File.ftype(fifo)}")
when (!File.exist?(fifo))
  bash "Create Zabbix pipe FIFO at #{fifo}" do
    code    "mkfifo #{fifo} && chown #{node[:users]['zabbix'][:uid]}:#{node[:groups]['zabbix'][:gid]} #{fifo} && chmod 662 #{fifo}"
    creates fifo
  end
else
  # fifo exists, do nothing
end

zabbix_server_ip = default_zabbix_server_ip
runit_service "zabbix_pipe" do
  options :server => zabbix_server_ip
end

announce(:zabbix, :pipe, {
           :logs    => { :pipe => '/etc/sv/zabbix_pipe/log/main/current' },
           :daemons => { :pipe => 'zabbix_pipe' }
         })
