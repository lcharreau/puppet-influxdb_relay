# influxdb_relay::install
#
# This class is called from influxdb_relay
#
class influxdb_relay::install {
  exec { 'install influxdb-relay':
    command => 'go get -u github.com/influxdata/influxdb-relay',
    path    => "${::influxdb_relay::go_bin_dir}:${::influxdb_relay::go_workspace}/bin:/usr/local/bin:/usr/bin:/bin",
    unless  => 'which influxdb-relay',
  }

  file { '/usr/bin/influxdb-relay':
    ensure  => 'link',
    target  => "${::influxdb_relay::go_workspace}/bin/influxdb-relay",
    require => Exec['install influxdb-relay'],
  }

  $user  = $::influxdb_relay::user
  $group = $::influxdb_relay::group

  group { $group:
    ensure => present,
    system => true,
  }
  user { $user:
    ensure  => present,
    system  => true,
    home    => $::influxdb_relay::data_dir,
    shell   => '/bin/false',
    gid     => $group,
    require => Group[$group],
    before  => [
      File[$::influxdb_relay::data_dir],
      File[$::influxdb_relay::log_dir],
    ],
  }

  $data_dir = $::influxdb_relay::data_dir
  $log_dir  = $::influxdb_relay::log_dir

  file { [$data_dir, $log_dir]:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  file { '/etc/logrotate.d/influxdb-relay':
    ensure  => file,
    content => template('influxdb_relay/logrotate.erb'),
  }
}
