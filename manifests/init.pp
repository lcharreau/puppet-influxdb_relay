# influxdb_relay
#
# @summary Installs and manages influxdb-relay, a basic high availability layer to InfluxDB.
#
# @example
#   include influxdb_relay
#
# @param user User to run influxdb-relay as. Default: 'influxdb-relay'
# @param group Group to run influxdb-relay as. Default: 'influxdb-relay'
# @param manage_service Whether to manage the influxdb-relay service. Default: true
# @param service_enable Whether to enable the influxdb-relay service. Default: true
# @param service_ensure Desired service state. Default: 'running'
# @param http_name Name of the HTTP server. Default: "${::facts['networking']['fqdn']}-http"
# @param http_bind_address TCP address to bind to for HTTP server. Default: $::facts['networking']['ip']
# @param http_bind_port TCP port to bind to for HTTP server. Default: 9096
# @param http_backends A hash of InfluxDB instances to use as HTTP backends for relay. See examples.
# @param udp_name Name of the UDP server. Default: "${::facts['networking']['fqdn']}-udp"
# @param udp_bind_address UDP address to bind to. Default: $::facts['networking']['ip']
# @param udp_bind_port UDP port to bind to. Default: 9096
# @param udp_read_buffer Socket buffer size for incoming connections. Default: 0
# @param precision Precision to use for timestamps. Default: 'n'
# @param udp_backends A hash of InfluxDB instances to use as UDP backends for relay. See examples.
# @param ssl_cert_name Name of the ssl cert file to use for HTTPS requests. Optional.
# @param ssl_dir Path to the directory of the ssl cert. Defaults to OS default cert store.
# @param cfg_dir Path to the config file directory. Default: '/etc/influxdb-relay'
# @param data_dir Path to the influxdb-relay data directory. Default: '/var/lib/influxdb-relay'
# @param log_dir Path to the influxdb-relay log directory. Default: '/var/log/influxdb-relay'
# @param go_bin_dir Path to the Go bin path. Default: '/usr/local/go/bin'
# @param go_workspace Path to the Go workspace. Default: '/usr/local/src/go'
#
class influxdb_relay (
  String                    $user              = 'influxdb-relay',
  String                    $group             = 'influxdb-relay',
  Boolean                   $manage_service    = true,
  Boolean                   $service_enable    = true,
  Enum['running','stopped'] $service_ensure    = 'running',
  String                    $http_name         = "${::facts['networking']['fqdn']}-http",
  String                    $http_bind_address = $::facts['networking']['ip'],
  Integer                   $http_bind_port    = 9096,
  Hash                      $http_backends     = {},
  String                    $udp_name          = "${::facts['networking']['fqdn']}-udp",
  String                    $udp_bind_address  = $::facts['networking']['ip'],
  Integer                   $udp_bind_port     = 9096,
  Integer                   $udp_read_buffer   = 0,
  String                    $precision         = 'n',
  Hash                      $udp_backends      = {},
  Optional[String]          $ssl_cert_name     = undef,
  Stdlib::Absolutepath      $ssl_dir           = $::influxdb_relay::params::ssl_dir,
  Stdlib::Absolutepath      $cfg_dir           = '/etc/influxdb-relay',
  Stdlib::Absolutepath      $data_dir          = '/var/lib/influxdb-relay',
  Stdlib::Absolutepath      $log_dir           = '/var/log/influxdb-relay',
  Stdlib::Absolutepath      $go_bin_dir        = '/usr/local/go/bin',
  Stdlib::Absolutepath      $go_workspace      = '/usr/local/src/go',
) inherits influxdb_relay::params {

  class { '::influxdb_relay::install': }
  -> class { '::influxdb_relay::config': }
  ~> class { '::influxdb_relay::service': }
  -> Class['::influxdb_relay']
}
