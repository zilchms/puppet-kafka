# frozen_string_literal: true

require 'spec_helper_acceptance'

case fact('osfamily')
when 'RedHat', 'Suse'
  user_shell = '/sbin/nologin'
when 'Debian'
  user_shell = '/usr/sbin/nologin'
end

# rubocop:disable RSpec/RepeatedExampleGroupBody
describe 'kafka::consumer' do
  it 'works with no errors' do
    pp = <<-EOS
      class { 'kafka::consumer':
        service_config => {
          topic            => 'demo',
          bootstrap-server => 'localhost:9092',
        },
      }
    EOS

    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe 'kafka::consumer::install' do
    context 'with default parameters' do
      it 'works with no errors' do
        pp = <<-EOS
          class { 'kafka::consumer':
            service_config => {
              topic            => 'demo',
              bootstrap-server => 'localhost:9092',
            },
          }
        EOS

        apply_manifest(pp, catch_failures: true)
      end

      describe group('kafka') do
        it { is_expected.to exist }
      end

      describe user('kafka') do
        it { is_expected.to exist }
        it { is_expected.to belong_to_group 'kafka' }
        it { is_expected.to have_login_shell user_shell }
      end

      describe file('/var/tmp/kafka') do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'kafka' }
        it { is_expected.to be_grouped_into 'kafka' }
      end

      describe file('/opt/kafka-2.12-2.4.1') do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'kafka' }
        it { is_expected.to be_grouped_into 'kafka' }
      end

      describe file('/opt/kafka') do
        it { is_expected.to be_linked_to('/opt/kafka-2.12-2.4.1') }
      end

      describe file('/opt/kafka/config') do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'kafka' }
        it { is_expected.to be_grouped_into 'kafka' }
      end

      describe file('/var/log/kafka') do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'kafka' }
        it { is_expected.to be_grouped_into 'kafka' }
      end
    end
  end

  describe 'kafka::consumer::config' do
    context 'with default parameters' do
      it 'works with no errors' do
        pp = <<-EOS
          class { 'kafka::consumer':
            service_config => {
              topic            => 'demo',
              bootstrap-server => 'localhost:9092',
            },
          }
        EOS

        apply_manifest(pp, catch_failures: true)
      end

      describe file('/opt/kafka/config/consumer.properties') do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'kafka' }
        it { is_expected.to be_grouped_into 'kafka' }
      end
    end

    context 'with custom config_dir' do
      it 'works with no errors' do
        pp = <<-EOS
          class { 'kafka::consumer':
            service_config => {
              topic            => 'demo',
              bootstrap-server => 'localhost:9092',
            },
            config_dir => '/opt/kafka/custom_config',
          }
        EOS

        apply_manifest(pp, catch_failures: true)
      end

      describe file('/opt/kafka/custom_config/consumer.properties') do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'kafka' }
        it { is_expected.to be_grouped_into 'kafka' }
      end
    end
  end

  describe 'kafka::consumer::service' do
    context 'with default parameters' do
      it 'works with no errors' do
        pp = <<-EOS
          class { 'kafka::consumer':
            service_config => {
              topic            => 'demo',
              bootstrap-server => 'localhost:9092',
            },
          }
        EOS

        apply_manifest(pp, catch_failures: true)
      end

      describe file('/etc/systemd/system/kafka-consumer.service') do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'root' }
        it { is_expected.to be_grouped_into 'root' }
        it { is_expected.to contain 'Environment=\'KAFKA_JMX_OPTS=-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=9993\'' }
        it { is_expected.to contain 'Environment=\'KAFKA_LOG4J_OPTS=-Dlog4j.configuration=file:/opt/kafka/config/log4j.properties\'' }
      end

      describe service('kafka-consumer') do
        it { is_expected.to be_running }
        it { is_expected.to be_enabled }
      end
    end
  end
end
# rubocop:enable RSpec/RepeatedExampleGroupBody
