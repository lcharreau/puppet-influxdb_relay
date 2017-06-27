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

  $http_backends = {
    local1 => {
      location => "http://${::ipaddress}:8086/write",
      params   => {
        timeout => '10s',
      },
    },
    local2 => {
      location => "http://${::ipaddress}:7086/write",
      params   => {
        timeout => '10s',
      },
    },
  }

  $udp_backends = {
    local1 => {
      location => "${::ipaddress}:8089",
      params   => {
        mtu => 512,
      },
    },
    local2 => {
      location => "${::ipaddress}:7089",
      params   => {
        mtu => 1024,
      },
    },
  }
}
