require 'spec_helper'

describe 'influxdb_relay' do
  on_supported_os.each do |os, os_facts|
    context "with default parameters on #{os}" do
      let(:facts) { os_facts }
      let(:conf_content) { '[[http]]
name = "foo.example.com-http"
bind-addr = "172.16.254.254:9096"

output = [
  { name="local1", location="http://172.16.254.254:8086/write", timeout="10s" },
  { name="local2", location="http://172.16.254.254:7086/write", timeout="10s" },
]

[[udp]]
name = "foo.example.com-udp"
bind-addr = "172.16.254.254:9096"
read-buffer = 0
precision = "n"

output = [
  { name="local1", location="172.16.254.254:8089", mtu=512 },
  { name="local2", location="172.16.254.254:7089", mtu=1024 },
]
'
      }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('influxdb_relay') }
      it { is_expected.to contain_class('influxdb_relay::params') }
      it { is_expected.to contain_class('influxdb_relay::install').that_comes_before('Class[influxdb_relay::config]') }
      it { is_expected.to contain_class('influxdb_relay::config').that_notifies('Class[influxdb_relay::service]') }
      it { is_expected.to contain_class('influxdb_relay::service') }

      it { is_expected.to contain_exec('install influxdb-relay').with(
        command: 'go get -u github.com/influxdata/influxdb-relay',
        path: '/usr/local/go/bin:/usr/local/src/go/bin:/usr/local/bin:/usr/bin:/bin',
        unless: 'which influxdb-relay',
        )
      }
      it { is_expected.to contain_file('/usr/bin/influxdb-relay').with(
        ensure: 'link',
        target: '/usr/local/src/go/bin/influxdb-relay',
        ).that_requires('Exec[install influxdb-relay]')
      }

      it { is_expected.to contain_group('influxdb-relay').with(
        ensure: 'present',
        system: true,
        )
      }
      it { is_expected.to contain_user('influxdb-relay').with(
        ensure: 'present',
        system: true,
        home: '/var/lib/influxdb-relay',
        shell: '/bin/false',
        gid: 'influxdb-relay',
        ).that_requires('Group[influxdb-relay]').that_comes_before(
          [
            'File[/var/lib/influxdb-relay]',
            'File[/var/log/influxdb-relay]',
          ]
        )
      }

      it { is_expected.to contain_file('/var/lib/influxdb-relay').with(
        ensure: 'directory',
        owner: 'influxdb-relay',
        group: 'influxdb-relay',
        )
      }
      it { is_expected.to contain_file('/var/log/influxdb-relay').with(
        ensure: 'directory',
        owner: 'influxdb-relay',
        group: 'influxdb-relay',
        )
      }
      it { is_expected.to contain_file('/etc/logrotate.d/influxdb-relay').with(
        ensure: 'file',
        ).with_content(
          %r{/var/log/influxdb-relay/influxdb-relay.log}
        )
      }

      it { is_expected.to contain_file('/etc/influxdb-relay').with_ensure('directory') }
      it { is_expected.to contain_file('/etc/influxdb-relay/influxdb-relay.conf').with(
        ensure: 'file',
        mode: '0644',
        content: conf_content,
        ).that_requires('File[/etc/influxdb-relay]')
      }

      case os_facts[:osfamily]
      when 'Debian'
        case os_facts[:operatingsystemmajrelease]
        when '8', '16.04'
          it { is_expected.to contain_file('/lib/systemd/system/influxdb-relay.service').with(
            ensure: 'file',
            mode: '0644',
            ).with_content(
              %r{\[Service\]\nUser=influxdb-relay\nGroup=influxdb-relay\nLimitNOFILE=65536\nExecStart=/usr/bin/influxdb-relay -config /etc/influxdb-relay/influxdb-relay.conf\n}
            ).that_comes_before('Service[influxdb-relay]')
          }
        else
          it { is_expected.to contain_file('/etc/init.d/influxdb-relay').with(
            ensure: 'file',
            mode: '0755',
            ).with_content(
              %r{# User and group\nUSER=influxdb-relay\nGROUP=influxdb-relay\n\n# Log directory\nLOG_DIR=/var/log/influxdb-relay\n# Configuration file\nCONFIG=/etc/influxdb-relay/influxdb-relay.conf\n}
            ).that_comes_before('Service[influxdb-relay]')
          }
        end
      when 'RedHat'
        case os_facts[:operatingsystemmajrelease]
        when '7'
          it { is_expected.to contain_file('/lib/systemd/system/influxdb-relay.service').with(
            ensure: 'file',
            mode: '0644',
            ).with_content(
              %r{\[Service\]\nUser=influxdb-relay\nGroup=influxdb-relay\nLimitNOFILE=65536\nExecStart=/usr/bin/influxdb-relay -config /etc/influxdb-relay/influxdb-relay.conf\n}
            ).that_comes_before('Service[influxdb-relay]')
          }
        else
          it { is_expected.to contain_file('/etc/init.d/influxdb-relay').with(
            ensure: 'file',
            mode: '0755',
            ).with_content(
              %r{# User and group\nUSER=influxdb-relay\nGROUP=influxdb-relay\n\n# Log directory\nLOG_DIR=/var/log/influxdb-relay\n# Configuration file\nCONFIG=/etc/influxdb-relay/influxdb-relay.conf\n}
            ).that_comes_before('Service[influxdb-relay]')
          }
        end
      end

      it { is_expected.to contain_service('influxdb-relay').with(
        ensure: 'running',
        enable: true,
        hasrestart: true,
        hasstatus: true,
        )
      }
    end
    context "with parameter overrides on #{os}" do
      let(:facts) { os_facts }
      let(:params) {{
        user: 'specuser',
        group: 'specgroup',
        service_enable: false,
        service_ensure: 'stopped',
        http_name: 'spec-http',
        http_bind_address: '1.2.3.4',
        http_bind_port: 9097,
        http_backends: {
          'spec1' => {
            'location' => 'http://10.2.3.4:8087/write',
            'params' => {
              'buffer-size-mb' => 100,
              'max-batch-kb' => 50,
              'max-delay-interval' => '5s',
            },
          },
          'spec2' => {
            'location' => 'http://10.2.3.5:8087/write',
            'params' => {
              'buffer-size-mb' => 100,
              'max-batch-kb' => 50,
              'max-delay-interval' => '5s',
            },
          },
        },
        udp_name: 'spec-udp',
        udp_bind_address: '2.3.4.5',
        udp_bind_port: 9097,
        udp_read_buffer: 8192,
        udp_backends: {
          'spec1' => {
            'location' => '10.2.3.4:7089',
            'params' => {
              'mtu' => 1024,
            },
          },
          'spec2' => {
            'location' => '10.2.3.5:8089',
            'params' => {
              'mtu' => 512,
            },
          },
        },
        precision: 'ms',
        ssl_cert_name: 'spec.pem',
        ssl_dir: '/path/to/ssl/dir',
        cfg_dir: '/path/to/cfg/dir',
        data_dir: '/path/to/data/dir',
        log_dir: '/path/to/log/dir',
        go_bin_dir: '/path/to/go/bin',
        go_workspace: '/path/to/workspace',
      }}
      let(:debian_content) { '[[http]]
name = "spec-http"
bind-addr = "1.2.3.4:9097"
ssl-combined-pem = "/path/to/ssl/dir/spec.pem"

output = [
  { name="spec1", location="http://10.2.3.4:8087/write", buffer-size-mb=100, max-batch-kb=50, max-delay-interval="5s" },
  { name="spec2", location="http://10.2.3.5:8087/write", buffer-size-mb=100, max-batch-kb=50, max-delay-interval="5s" },
]

[[udp]]
name = "spec-udp"
bind-addr = "2.3.4.5:9097"
read-buffer = 8192
precision = "ms"

output = [
  { name="spec1", location="10.2.3.4:7089", mtu=1024 },
  { name="spec2", location="10.2.3.5:8089", mtu=512 },
]
'
      }
      let(:redhat_content) { '[[http]]
name = "spec-http"
bind-addr = "1.2.3.4:9097"
ssl-combined-pem = "/path/to/ssl/dir/spec.pem"

output = [
  { name="spec1", location="http://10.2.3.4:8087/write", buffer-size-mb=100, max-batch-kb=50, max-delay-interval="5s" },
  { name="spec2", location="http://10.2.3.5:8087/write", buffer-size-mb=100, max-batch-kb=50, max-delay-interval="5s" },
]

[[udp]]
name = "spec-udp"
bind-addr = "2.3.4.5:9097"
read-buffer = 8192
precision = "ms"

output = [
  { name="spec1", location="10.2.3.4:7089", mtu=1024 },
  { name="spec2", location="10.2.3.5:8089", mtu=512 },
]
'
      }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('influxdb_relay') }
      it { is_expected.to contain_class('influxdb_relay::params') }
      it { is_expected.to contain_class('influxdb_relay::install').that_comes_before('Class[influxdb_relay::config]') }
      it { is_expected.to contain_class('influxdb_relay::config').that_notifies('Class[influxdb_relay::service]') }
      it { is_expected.to contain_class('influxdb_relay::service') }

      it { is_expected.to contain_exec('install influxdb-relay').with(
        command: 'go get -u github.com/influxdata/influxdb-relay',
        path: '/path/to/go/bin:/path/to/workspace/bin:/usr/local/bin:/usr/bin:/bin',
        unless: 'which influxdb-relay',
        )
      }
      it { is_expected.to contain_file('/usr/bin/influxdb-relay').with(
        ensure: 'link',
        target: '/path/to/workspace/bin/influxdb-relay',
        ).that_requires('Exec[install influxdb-relay]')
      }

      it { is_expected.to contain_group('specgroup').with(
        ensure: 'present',
        system: true,
        )
      }
      it { is_expected.to contain_user('specuser').with(
        ensure: 'present',
        system: true,
        home: '/path/to/data/dir',
        shell: '/bin/false',
        gid: 'specgroup',
        ).that_requires('Group[specgroup]').that_comes_before(
          [
            'File[/path/to/data/dir]',
            'File[/path/to/log/dir]',
          ]
        )
      }

      it { is_expected.to contain_file('/path/to/data/dir').with(
        ensure: 'directory',
        owner: 'specuser',
        group: 'specgroup',
        )
      }
      it { is_expected.to contain_file('/path/to/log/dir').with(
        ensure: 'directory',
        owner: 'specuser',
        group: 'specgroup',
        )
      }
      it { is_expected.to contain_file('/etc/logrotate.d/influxdb-relay').with(
        ensure: 'file',
        ).with_content(
          %r{/path/to/log/dir/influxdb-relay.log}
        )
      }

      it { is_expected.to contain_file('/path/to/cfg/dir').with_ensure('directory') }

      case os_facts[:osfamily]
      when 'Debian'
        it { is_expected.to contain_file('/path/to/cfg/dir/influxdb-relay.conf').with(
          ensure: 'file',
          mode: '0644',
          content: debian_content,
          ).that_requires('File[/path/to/cfg/dir]')
        }

        case os_facts[:operatingsystemmajrelease]
        when '8', '16.04'
          it { is_expected.to contain_file('/lib/systemd/system/influxdb-relay.service').with(
            ensure: 'file',
            mode: '0644',
            ).with_content(
              %r{\[Service\]\nUser=specuser\nGroup=specgroup\nLimitNOFILE=65536\nExecStart=/usr/bin/influxdb-relay -config /path/to/cfg/dir/influxdb-relay.conf\n}
            ).that_comes_before('Service[influxdb-relay]')
          }
        else
          it { is_expected.to contain_file('/etc/init.d/influxdb-relay').with(
            ensure: 'file',
            mode: '0755',
            ).with_content(
              %r{# User and group\nUSER=specuser\nGROUP=specgroup\n\n# Log directory\nLOG_DIR=/path/to/log/dir\n# Configuration file\nCONFIG=/path/to/cfg/dir/influxdb-relay.conf\n}
            ).that_comes_before('Service[influxdb-relay]')
          }
        end
      when 'RedHat'
        it { is_expected.to contain_file('/path/to/cfg/dir/influxdb-relay.conf').with(
          ensure: 'file',
          mode: '0644',
          content: redhat_content,
          ).that_requires('File[/path/to/cfg/dir]')
        }

        case os_facts[:operatingsystemmajrelease]
        when '7'
          it { is_expected.to contain_file('/lib/systemd/system/influxdb-relay.service').with(
            ensure: 'file',
            mode: '0644',
            ).with_content(
              %r{\[Service\]\nUser=specuser\nGroup=specgroup\nLimitNOFILE=65536\nExecStart=/usr/bin/influxdb-relay -config /path/to/cfg/dir/influxdb-relay.conf\n}
            ).that_comes_before('Service[influxdb-relay]')
          }
        else
          it { is_expected.to contain_file('/etc/init.d/influxdb-relay').with(
            ensure: 'file',
            mode: '0755',
            ).with_content(
              %r{# User and group\nUSER=specuser\nGROUP=specgroup\n\n# Log directory\nLOG_DIR=/path/to/log/dir\n# Configuration file\nCONFIG=/path/to/cfg/dir/influxdb-relay.conf\n}
            ).that_comes_before('Service[influxdb-relay]')
          }
        end
      end

      it { is_expected.to contain_service('influxdb-relay').with(
        ensure: 'stopped',
        enable: false,
        hasrestart: true,
        hasstatus: true,
        )
      }
    end
    context "when not managing the service on #{os}" do
      let(:facts) { os_facts }
      let(:params) {{
        manage_service: false,
      }}

      case os_facts[:osfamily]
      when 'Debian'
        case os_facts[:operatingsystemmajrelease]
        when '8', '16.04'
          it { is_expected.not_to contain_file('/lib/systemd/system/influxdb-relay.service') }
        else
          it { is_expected.not_to contain_file('/etc/init.d/influxdb-relay') }
        end
      when 'RedHat'
        case os_facts[:operatingsystemmajrelease]
        when '7'
          it { is_expected.not_to contain_file('/lib/systemd/system/influxdb-relay.service') }
        else
          it { is_expected.not_to contain_file('/etc/init.d/influxdb-relay') }
        end
      end

      it { is_expected.not_to contain_service('influxdb-relay') }
    end
  end
  context 'class on an unsupported OS' do
    let(:facts) {{
      osfamily:        'Solaris',
      operatingsystem: 'Nexenta',
    }}

    it { expect { is_expected.to contain_class('influxdb_relay') }.to raise_error(Puppet::PreformattedError, /Solaris not supported/) }
  end
end
