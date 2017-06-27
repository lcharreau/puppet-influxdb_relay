# influxdb_relay::service
#
# This class is called from influxdb_relay
#
class influxdb_relay::service {
  $user    = $::influxdb_relay::user
  $group   = $::influxdb_relay::group
  $cfg_dir = $::influxdb_relay::cfg_dir
  $log_dir = $::influxdb_relay::log_dir

  if $::influxdb_relay::service_type == 'systemd' {
    $service_file = '/lib/systemd/system/influxdb-relay.service'
    $service_mode = '0644'
  }
  else {
    $service_file = '/etc/init.d/influxdb-relay'
    $service_mode = '0755'
  }

  if $::influxdb_relay::manage_service {
    file { $service_file:
      ensure  => file,
      mode    => $service_mode,
      content => template("influxdb_relay/${::influxdb_relay::service_type}.erb"),
      before  => Service['influxdb-relay'],
    }

    service { 'influxdb-relay':
      ensure     => $::influxdb_relay::service_ensure,
      enable     => $::influxdb_relay::service_enable,
      hasrestart => true,
      hasstatus  => true,
    }
  }
}
