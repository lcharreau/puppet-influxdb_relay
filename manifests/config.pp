# influxdb_relay::config
#
# This class is called from influxdb_relay
#
class influxdb_relay::config {
  $cfg_dir           = $::influxdb_relay::cfg_dir
  $http_name         = $::influxdb_relay::http_name
  $http_bind_address = $::influxdb_relay::http_bind_address
  $http_bind_port    = $::influxdb_relay::http_bind_port
  $http_backends     = $::influxdb_relay::http_backends
  $udp_name          = $::influxdb_relay::udp_name
  $udp_bind_address  = $::influxdb_relay::udp_bind_address
  $udp_bind_port     = $::influxdb_relay::udp_bind_port
  $udp_backends      = $::influxdb_relay::udp_backends
  $udp_read_buffer   = $::influxdb_relay::udp_read_buffer
  $precision         = $::influxdb_relay::precision
  $ssl_cert_name     = $::influxdb_relay::ssl_cert_name
  if $ssl_cert_name {
    $ssl_dir  = $::influxdb_relay::ssl_dir
    $ssl_cert = "${ssl_dir}/${ssl_cert_name}"
  }

  if empty($http_backends) and empty($udp_backends) {
    $real_http_backends = {
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
    $real_udp_backends = undef
  }
  else {
    if ! empty($http_backends) {
      $real_http_backends = $http_backends
    }
    else {
      $real_http_backends = undef
    }

    if ! empty($udp_backends) {
      $real_udp_backends = $udp_backends
    }
    else {
      $real_udp_backends = undef
    }
  }

  if $real_http_backends {
    $http_outputs = $real_http_backends.map |$key, $value| {
      $http_array = [
        "name=\"${key}\"",
        "location=\"${value['location']}\"",
      ]
      $http_params = $value['params'].map |$k, $v| {
        if type($v) =~ Type[String] {
          $safe_val = "\"${v}\""
        }
        else {
          $safe_val = $v
        }
        "${k}=${safe_val}"
      }
      join($http_array + $http_params, ', ')
    }
  }

  if $real_udp_backends {
    $udp_outputs = $real_udp_backends.map |$key, $value| {
      $udp_array = [
        "name=\"${key}\"",
        "location=\"${value['location']}\"",
      ]
      $udp_params = $value['params'].map |$k, $v| {
        if type($v) =~ Type[String] {
          $safe_val = "\"${v}\""
        }
        else {
          $safe_val = $v
        }
        "${k}=${safe_val}"
      }
      join($udp_array + $udp_params, ', ')
    }
  }

  file { $cfg_dir:
    ensure => directory,
  }
  file { "${cfg_dir}/influxdb-relay.conf":
    ensure  => file,
    mode    => '0644',
    content => template('influxdb_relay/conf.erb'),
    require => File[$cfg_dir],
  }
}
