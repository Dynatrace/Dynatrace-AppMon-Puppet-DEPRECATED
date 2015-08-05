require 'json'
require 'net/http'
require 'serverspec'

# Required by serverspec
set :backend, :exec

describe user('dynatrace') do
  it { should exist }
  it { should belong_to_group 'dynatrace' }
end

describe file('/opt/dynatrace') do
  it { should be_directory }
  it { should be_symlink }
end

describe file('/opt/dynatrace/agent') do
  it { should be_directory }
  it { should be_owned_by 'dynatrace' }
  it { should be_grouped_into 'dynatrace' }
end

describe file('/opt/dynatrace/server') do
  it { should be_directory }
  it { should be_owned_by 'dynatrace' }
  it { should be_grouped_into 'dynatrace' }
end

describe file ('/etc/init.d/dynaTraceServer') do
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }

  if os[:family] == 'debian' || os[:family] == 'ubuntu'
    its(:content) { should match /^\# Default-Start: 2 3 4 5$/ }
    its(:content) { should match /^\# Default-Stop: 0 1 6$/ }
  elsif os[:family] == 'redhat'
    its(:content) { should match /^\# Default-Start: 3 5$/ }
    its(:content) { should match /^\# Default-Stop: 0 1 2 6$/ }
  end

  its(:content) { should match /^DT_HOME=\/opt\/dynatrace$/ }
  its(:content) { should match /^DT_OPTARGS="-listen 6698"$/ }
  its(:content) { should match /^.*su - dynatrace -c.*$/ }
end

describe service('dynaTraceServer') do
  it { should be_enabled }
  it { should be_running }

  if os[:family] == 'debian' || os[:family] == 'ubuntu'
      it { should be_enabled.with_level(3) }
      it { should be_enabled.with_level(4) }
      it { should be_enabled.with_level(5) }
  end
end

describe port(2021) do
  it { should be_listening }
end

describe port(6698) do
  it { should be_listening }
end

describe port(6699) do
  it { should be_listening }
end

describe port(8020) do
  it { should be_listening }
end

describe port(8021) do
  it { should be_listening }
end
