# influxdb_relay::params
#
# This class sets parameters according to platform
#
class influxdb_relay::params {

  case $::facts['os']['family'] {
    'Debian': {
      $ssl_dir = '/etc/ssl'
      case $::facts['os']['release']['major'] {
        '8', '16.04': {
          $service_type = 'systemd'
        }
        default: {
          $service_type = 'init'
        }
      }
    }
    'RedHat': {
      $ssl_dir = '/etc/pki/tls/certs'
      case $::facts['os']['release']['major'] {
        '7': {
          $service_type = 'systemd'
        }
        default: {
          $service_type = 'init'
        }
      }
    }
    default: {
      fail("${::facts['os']['family']} not supported")
    }
  }
}
