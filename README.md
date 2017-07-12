# InfluxDB Relay module for Puppet

[![Build Status](https://travis-ci.org/spacepants/puppet-influxdb_relay.png?branch=master)](https://travis-ci.org/spacepants/puppet-influxdb_relay)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with InfluxDB Relay](#setup)
    * [What InfluxDB Relay affects](#what-InfluxDB Relay-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with InfluxDB Relay](#beginning-with-InfluxDB Relay)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module allows you to install and manage [InfluxDB Relay](https://github.com/influxdata/influxdb-relay).

## Module Description

This module installs and configures InfluxDB Relay, a basic high availability layer to InfluxDB.

## Setup

### InfluxDB Relay prerequisites

* InfluxDB Relay requires Go 1.5+. This can be done using the [dcoxall-golang](https://github.com/dcoxall/dcoxall-golang) module.
* You'll also need `git` installed and available on your path.

### What InfluxDB Relay affects

* A daemon user. Default: `influxdb-relay`
* The data directory. Default: `/var/lib/influxdb-relay`
* The log directory. Default: `/var/log/influxdb-relay`
* A logrotate rule.
* The config file.
* The influxdb-relay service. Note: Service management can be disabled.

### Beginning with InfluxDB Relay

#### Examples

##### Basic example

```puppet
include ::influxdb_relay
```

Out of the box the module will set up a basic config. This sets up an HTTP server listening on the node's IP at port 9096, configured for two InfluxDB HTTP backends running on the same node on ports 7086 and 8086, respectively.

For a node with an FQDN of _foo.example.com_ and an IP of _172.16.254.254_, its rendered config file would look like this:

```
[[http]]
name = "foo.example.com-http"
bind-addr = "172.16.254.254:9096"

output = [
  { name="local1", location="http://172.16.254.254:8086/write", timeout="10s" },
  { name="local2", location="http://172.16.254.254:7086/write", timeout="10s" },
]
```

##### Setting HTTP backends

HTTP backends can be declared like in the following example:

```puppet
class { '::influxdb_relay':
  http_backends => {
    backend1 => {
      location => 'http://10.2.3.4:8086/write',
      params   => {
        timeout => '10s',
      },
    },
    backend2 => {
      location => 'http://10.5.6.7:8086/write',
      params   => {
        timeout => '10s',
      },
    },
  },
}

```

##### HTTP backend parameters

Additional options such as [buffering failed requests](https://github.com/influxdata/influxdb-relay#buffering) can be accomplished by providing the desired parameters.

```puppet
class { '::influxdb_relay':
  http_backends => {
    backend1 => {
      location => 'http://10.2.3.4:8086/write',
      params   => {
        'buffer-size-mb'     => 100,
        'max-batch-kb'       => 50,
        'max-delay-interval' => '5s',
      },
    },
  },
}
```

##### UDP backends

UDP backends are specified similarly to HTTP backends.

```puppet
class { '::influxdb_relay':
  udp_backends => {
    backend1 => {
      location => '10.2.3.4:8089',
      params   => {
        mtu => 1024,
      },
    },
  },
}
```

##### Enabling SSL

Enabling SSL can be accomplished by providing the filename of the combined PEM certificate.

```puppet
class { '::influxdb_relay':
  ssl_cert_name => 'certificate.pem',
}
```

By default, the module presumes that the certificate is in the OS default certificate store, (`/etc/ssl` on Debian family systems, `/etc/pki/tls/certs` on RedHat family systems) but this can be overridden by providing the path to the directory.

```puppet
class { '::influxdb_relay':
  ssl_cert_name => 'certificate.pem',
  ssl_dir       => '/path/to/your/directory',
}
```

## Reference

### Classes

#### Public Classes

* `influxdb_relay`: Main class, manages the installation and configuration of influxdb-relay

#### Private Classes

* `influxdb_relay::install`: Installs influxdb-relay
* `influxdb_relay::config`: Modifies influxdb-relay configuration files
* `influxdb_relay::service`: Manages the influxdb-relay service

### Parameters

#### `user`

The user to run influxdb-relay as. Default: `influxdb-relay`

#### `group`

The group to run influxdb-relay as. Default: `influxdb-relay`

#### `manage_service`

Whether to manage the influxdb-relay service. Default: true

#### `service_enable`

Whether to enable the influxdb-relay service. Default: true

#### `service_ensure`

Desired service state. Default: 'running'

#### `http_name`

Name of the HTTP server. Default: "${::fqdn}-http"

#### `http_bind_address`

TCP address to bind to for HTTP server. Default: $::ipaddress

#### `http_bind_port`

TCP port to bind to for HTTP server. Default: 9096

#### `http_backends`

A hash of InfluxDB instances to use as HTTP backends for relay. See examples.

#### `udp_name`

Name of the UDP server. Default: "${::fqdn}-udp"

#### `udp_bind_address`

UDP address to bind to. Default: $::ipaddress

#### `udp_bind_port`

UDP port to bind to. Default: 9096

#### `udp_read_buffer`

Socket buffer size for incoming connections. Default: 0

#### `precision`

Precision to use for timestamps. Default: 'n'

#### `udp_backends`

A hash of InfluxDB instances to use as UDP backends for relay. See examples.

#### `ssl_cert_name`

Name of the ssl cert file to use for HTTPS requests. Optional.

#### `ssl_dir`

Path to the directory of the ssl cert. Defaults to OS default cert store.

#### `cfg_dir`

Path to the config file directory. Default: '/etc/influxdb-relay'

#### `data_dir`

Path to the influxdb-relay data directory. Default: '/var/lib/influxdb-relay'

#### `log_dir`

Path to the influxdb-relay log directory. Default: '/var/log/influxdb-relay'

#### `go_bin_dir`

Path to the Go bin path. Default: '/usr/local/go/bin'

#### `go_workspace`

Path to the Go workspace. Default: '/usr/local/src/go'

## Limitations

This module is currently tested and working on RedHat and CentOS 6, and 7, Debian 7 and 8, and Ubuntu 12.04, 14.04, and 16.04 systems.

## Development

Pull requests welcome. Please see the contributing guidelines below.

### Contributing

1. Fork the repo.

2. Run the tests. We only take pull requests with passing tests, and
   it's great to know that you have a clean slate.

3. Add a test for your change. Only refactoring and documentation
   changes require no new tests. If you are adding functionality
   or fixing a bug, please add a test.

4. Make the test pass.

5. Push to your fork and submit a pull request.
