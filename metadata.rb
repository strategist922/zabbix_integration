maintainer        "Dhruv Bansal"
maintainer_email  "dhruv@infochimps.com"
license           "Apache 2.0"
description       "Integrates other services with Zabbix."
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "0.0.1"

supports "ubuntu",   ">= 10.04"
supports "debian",   ">= 6.0"

depends "runit"
depends "metachef"
depends "zabbix"

recipe "zabbix_integration::default",            "Does nothing by default; override to set up a base integration policy for nodes."

recipe "zabbix_integration::hosts",                "Registers and toggles the monitoring state of hosts, both real and virtual, by syncing Zabbix and Chef."
recipe "zabbix_integration::logs",                 "Monitors the sizes of log files on a node."
recipe "zabbix_integration::ports",                "Monitors the availability and performance of ports on a node."
recipe "zabbix_integration::daemons",              "Monitors running daemons on a node."

recipe "zabbix_integration::elasticsearch_monitor",      "Launches a daemon that monitors Elasticsearch clusters."
recipe "zabbix_integration::hbase_monitor",              "Launches a daemon that monitors HBase clusters."
recipe "zabbix_integration::redis_monitor",              "Launches a daemon that monitors Redis servers."
recipe "zabbix_integration::mongodb_monitor",            "Launches a daemon that monitors MongoDB servers."
recipe "zabbix_integration::flume_monitor",              "Launches a daemon that monitors Flume clusters."


attribute "zabbix_integration/pipe",
  :display_name          => "",
  :description           => "The location to set up a FIFO for writing data to Zabbix.",
  :default               => "/dev/zabbix"

#
# Logs
#

# Log file size check.
attribute "zabbix_integration/logs/file_size/max_size",
  :display_name          => "",
  :description           => "The default maximum allowed size (in MB) of a log file on disk before an alert is issued.",
  :default               => "200"

attribute "zabbix_integration/logs/file_size/priority",
  :display_name          => "",
  :description           => "The default priority of alerts due to log files that have grown too large.",
  :default               => "warning"

#
# Ports
#

# Port availability check.

attribute "zabbix_integration/ports/availability/window",
  :display_name          => "",
  :description           => "The number of prior seconds over which the availability of a port is measured.",
  :default               => "900"

attribute "zabbix_integration/ports/availability/failures",
  :display_name          => "",
  :description           => "The default maximum number of allowed failures to connect to a port within the availability window before an alert is issued.",
  :default               => "5"

attribute "zabbix_integration/ports/availability/priority",
  :display_name          => "",
  :description           => "The default priority of alerts due to ports that have had too many connection failures.",
  :default               => "high"

# Port performance check.

attribute "zabbix_integration/ports/response_time/window",
  :display_name          => "",
  :description           => "The number of prior seconds over which the response time of a port is averaged.",
  :default               => "900"

attribute "zabbix_integration/ports/response_time/average",
  :display_name          => "",
  :description           => "The default maximum average response time (in seconds) for a port before an alert is issued.",
  :default               => "3.0"

attribute "zabbix_integration/ports/response_time/priority",
  :display_name          => "",
  :description           => "The default priority of alerts due to ports with an average response time that has grown too high.",
  :default               => "warning"


#
# Daemons
#

# Running check
attribute "zabbix_integration/daemons/running/priority",
  :display_name          => "",
  :description           => "The default priority of alerts trigger because daemons weren't running.",
  :default               => "average"
