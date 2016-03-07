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

describe file ('/opt/dynatrace/agent/conf/dtwsagent.ini') do
  its(:content) { should match /^Name dtwsagent$/ }
  its(:content) { should match /^Server localhost:9998$/ }
  its(:content) { should match /^Loglevel info$/ }
end

describe file ('/etc/init.d/dynaTraceWebServerAgent') do
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
  its(:content) { should match /^DT_RUNASUSER=dynatrace$/ }
end

describe process('dtwsagent') do
  it { should be_running }
  its(:user) { should eq 'dynatrace' }
end

describe service('dynaTraceWebServerAgent') do
  it { should be_enabled }

  if os[:family] == 'debian' || os[:family] == 'ubuntu'
      it { should be_enabled.with_level(3) }
      it { should be_enabled.with_level(4) }
      it { should be_enabled.with_level(5) }
  end
end
