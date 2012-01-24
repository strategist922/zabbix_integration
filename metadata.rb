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

recipe "zabbix_integration::default",            "Sets up a named pipe at /dev/zabbix connected to a Zabbix server."
recipe "zabbix_integration::elasticsearch",      "Launches a daemon that monitors Elasticsearch clusters."
recipe "zabbix_integration::hbase",              "Launches a daemon that monitors HBase clusters."
recipe "zabbix_integration::redis",              "Launches a daemon that monitors Redis servers."
recipe "zabbix_integration::mongodb",            "Launches a daemon that monitors MongoDB servers."
recipe "zabbix_integration::flume",              "Launches a daemon that monitors Flume clusters."
