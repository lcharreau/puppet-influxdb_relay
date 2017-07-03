# influxdb_relay::params
#
# This class sets parameters according to platform
#
class influxdb_relay::params {

  case $::osfamily {
    'Debian': {
      $ssl_dir = '/etc/ssl'
      case $::operatingsystemmajrelease {
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
      case $::operatingsystemmajrelease {
        '7': {
          $service_type = 'systemd'
        }
        default: {
          $service_type = 'init'
        }
      }
    }
    default: {
      fail("${::osfamily} not supported")
    }
  }
}
