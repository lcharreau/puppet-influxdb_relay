require 'spec_helper_acceptance'

describe 'profiles class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'is expected to work idempotently with no errors' do
      golang_prep = <<-EOS
      class { '::golang':
        version => '1.7.4',
        workspace => '/usr/local/src/go',
      }
      package { 'git':
        ensure => installed,
      }
      EOS
      apply_manifest(golang_prep, catch_failures: true)

      pp = <<-EOS
      class { 'influxdb_relay': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe port(9096) do
      it { is_expected.to be_listening }
    end

    describe service('influxdb-relay') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
