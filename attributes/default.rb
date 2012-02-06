default[:zabbix_integration][:pipe] = '/dev/zabbix'

#
# Logs
#

# Log file size check.
default[:zabbix_integration][:logs][:file_size][:max_size] = 200
default[:zabbix_integration][:logs][:file_size][:priority] = :warning

#
# Ports
#

# Port availability check.
default[:zabbix_integration][:ports][:availability][:window]   = 900
default[:zabbix_integration][:ports][:availability][:failures] = 5
default[:zabbix_integration][:ports][:availability][:priority] = :high

# Port performance check.
default[:zabbix_integration][:ports][:response_time][:window]   = 900
default[:zabbix_integration][:ports][:response_time][:average]  = 3.0
default[:zabbix_integration][:ports][:response_time][:priority] = :warning
