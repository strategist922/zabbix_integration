define :zabbix_monitor, :packages => [], :gems => [], :loop => 30, :action => :enable do

  monitor      = params[:name]
  monitor_path = "/etc/zabbix/externalscripts/#{monitor}_monitor.rb"

  params[:packages].each do |package_name|
    package(package_name) do
      action :install
    end
  end

  params[:gems].each do |gem_name|
    gem_package(gem_name) do
      action :install
    end
  end

  template monitor_path  do
    source "#{monitor}_monitor.rb.erb"
    action :create
    notifies :restart, "service[#{monitor}_monitor]", :delayed
  end

  runit_service "#{monitor}_monitor" do
    template_name "zabbix_monitor"
    options :monitor_path => monitor_path, :loop => params[:loop]
  end
end
