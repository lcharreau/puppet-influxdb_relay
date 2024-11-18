# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`influxdb_relay`](#influxdb_relay): Installs and manages influxdb-relay, a basic high availability layer to InfluxDB.
* [`influxdb_relay::config`](#influxdb_relay--config): influxdb_relay::config  This class is called from influxdb_relay
* [`influxdb_relay::install`](#influxdb_relay--install): influxdb_relay::install  This class is called from influxdb_relay
* [`influxdb_relay::params`](#influxdb_relay--params): influxdb_relay::params  This class sets parameters according to platform
* [`influxdb_relay::service`](#influxdb_relay--service): influxdb_relay::service  This class is called from influxdb_relay

## Classes

### <a name="influxdb_relay"></a>`influxdb_relay`

influxdb_relay

#### Examples

##### 

```puppet
include influxdb_relay
```

#### Parameters

The following parameters are available in the `influxdb_relay` class:

* [`user`](#-influxdb_relay--user)
* [`group`](#-influxdb_relay--group)
* [`manage_service`](#-influxdb_relay--manage_service)
* [`service_enable`](#-influxdb_relay--service_enable)
* [`service_ensure`](#-influxdb_relay--service_ensure)
* [`http_name`](#-influxdb_relay--http_name)
* [`http_bind_address`](#-influxdb_relay--http_bind_address)
* [`http_bind_port`](#-influxdb_relay--http_bind_port)
* [`http_backends`](#-influxdb_relay--http_backends)
* [`udp_name`](#-influxdb_relay--udp_name)
* [`udp_bind_address`](#-influxdb_relay--udp_bind_address)
* [`udp_bind_port`](#-influxdb_relay--udp_bind_port)
* [`udp_read_buffer`](#-influxdb_relay--udp_read_buffer)
* [`precision`](#-influxdb_relay--precision)
* [`udp_backends`](#-influxdb_relay--udp_backends)
* [`ssl_cert_name`](#-influxdb_relay--ssl_cert_name)
* [`ssl_dir`](#-influxdb_relay--ssl_dir)
* [`cfg_dir`](#-influxdb_relay--cfg_dir)
* [`data_dir`](#-influxdb_relay--data_dir)
* [`log_dir`](#-influxdb_relay--log_dir)
* [`go_bin_dir`](#-influxdb_relay--go_bin_dir)
* [`go_workspace`](#-influxdb_relay--go_workspace)

##### <a name="-influxdb_relay--user"></a>`user`

Data type: `String`

User to run influxdb-relay as. Default: 'influxdb-relay'

Default value: `'influxdb-relay'`

##### <a name="-influxdb_relay--group"></a>`group`

Data type: `String`

Group to run influxdb-relay as. Default: 'influxdb-relay'

Default value: `'influxdb-relay'`

##### <a name="-influxdb_relay--manage_service"></a>`manage_service`

Data type: `Boolean`

Whether to manage the influxdb-relay service. Default: true

Default value: `true`

##### <a name="-influxdb_relay--service_enable"></a>`service_enable`

Data type: `Boolean`

Whether to enable the influxdb-relay service. Default: true

Default value: `true`

##### <a name="-influxdb_relay--service_ensure"></a>`service_ensure`

Data type: `Enum['running','stopped']`

Desired service state. Default: 'running'

Default value: `'running'`

##### <a name="-influxdb_relay--http_name"></a>`http_name`

Data type: `String`

Name of the HTTP server. Default: "${::facts['networking']['fqdn']}-http"

Default value: `"${::facts['networking']['fqdn']}-http"`

##### <a name="-influxdb_relay--http_bind_address"></a>`http_bind_address`

Data type: `String`

TCP address to bind to for HTTP server. Default: $::facts['networking']['ip']

Default value: `$::facts['networking']['ip']`

##### <a name="-influxdb_relay--http_bind_port"></a>`http_bind_port`

Data type: `Integer`

TCP port to bind to for HTTP server. Default: 9096

Default value: `9096`

##### <a name="-influxdb_relay--http_backends"></a>`http_backends`

Data type: `Hash`

A hash of InfluxDB instances to use as HTTP backends for relay. See examples.

Default value: `{}`

##### <a name="-influxdb_relay--udp_name"></a>`udp_name`

Data type: `String`

Name of the UDP server. Default: "${::facts['networking']['fqdn']}-udp"

Default value: `"${::facts['networking']['fqdn']}-udp"`

##### <a name="-influxdb_relay--udp_bind_address"></a>`udp_bind_address`

Data type: `String`

UDP address to bind to. Default: $::facts['networking']['ip']

Default value: `$::facts['networking']['ip']`

##### <a name="-influxdb_relay--udp_bind_port"></a>`udp_bind_port`

Data type: `Integer`

UDP port to bind to. Default: 9096

Default value: `9096`

##### <a name="-influxdb_relay--udp_read_buffer"></a>`udp_read_buffer`

Data type: `Integer`

Socket buffer size for incoming connections. Default: 0

Default value: `0`

##### <a name="-influxdb_relay--precision"></a>`precision`

Data type: `String`

Precision to use for timestamps. Default: 'n'

Default value: `'n'`

##### <a name="-influxdb_relay--udp_backends"></a>`udp_backends`

Data type: `Hash`

A hash of InfluxDB instances to use as UDP backends for relay. See examples.

Default value: `{}`

##### <a name="-influxdb_relay--ssl_cert_name"></a>`ssl_cert_name`

Data type: `Optional[String]`

Name of the ssl cert file to use for HTTPS requests. Optional.

Default value: `undef`

##### <a name="-influxdb_relay--ssl_dir"></a>`ssl_dir`

Data type: `Stdlib::Absolutepath`

Path to the directory of the ssl cert. Defaults to OS default cert store.

Default value: `$::influxdb_relay::params::ssl_dir`

##### <a name="-influxdb_relay--cfg_dir"></a>`cfg_dir`

Data type: `Stdlib::Absolutepath`

Path to the config file directory. Default: '/etc/influxdb-relay'

Default value: `'/etc/influxdb-relay'`

##### <a name="-influxdb_relay--data_dir"></a>`data_dir`

Data type: `Stdlib::Absolutepath`

Path to the influxdb-relay data directory. Default: '/var/lib/influxdb-relay'

Default value: `'/var/lib/influxdb-relay'`

##### <a name="-influxdb_relay--log_dir"></a>`log_dir`

Data type: `Stdlib::Absolutepath`

Path to the influxdb-relay log directory. Default: '/var/log/influxdb-relay'

Default value: `'/var/log/influxdb-relay'`

##### <a name="-influxdb_relay--go_bin_dir"></a>`go_bin_dir`

Data type: `Stdlib::Absolutepath`

Path to the Go bin path. Default: '/usr/local/go/bin'

Default value: `'/usr/local/go/bin'`

##### <a name="-influxdb_relay--go_workspace"></a>`go_workspace`

Data type: `Stdlib::Absolutepath`

Path to the Go workspace. Default: '/usr/local/src/go'

Default value: `'/usr/local/src/go'`

### <a name="influxdb_relay--config"></a>`influxdb_relay::config`

influxdb_relay::config

This class is called from influxdb_relay

### <a name="influxdb_relay--install"></a>`influxdb_relay::install`

influxdb_relay::install

This class is called from influxdb_relay

### <a name="influxdb_relay--params"></a>`influxdb_relay::params`

influxdb_relay::params

This class sets parameters according to platform

### <a name="influxdb_relay--service"></a>`influxdb_relay::service`

influxdb_relay::service

This class is called from influxdb_relay
