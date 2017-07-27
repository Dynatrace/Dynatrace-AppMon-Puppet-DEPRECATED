require 'serverspec'

# Required by serverspec
set :backend, :exec


describe file('/opt/dynatrace-oneagent-7.0') do
  it { should be_directory }
end

describe file('/opt/dynatrace-oneagent-7.0/agent/bin/linux-x86-64/liboneagentloader.so') do
  it { should exist }
end

describe file ('/etc/php/7.0/apache2/php.ini') do
  its(:content) { should match /^extension = \/opt\/dynatrace-oneagent-7.0\/agent\/bin\/linux-x86-64\/liboneagentloader.so$/ }
  its(:content) { should match /^phpagent.agentname = phpOneAgent$/ }
  its(:content) { should match /^phpagent.server = https:\/\/localhost:8043$/ }
  its(:content) { should match /^phpagent.tenant = 1$/ }
end

describe service('apache2') do
  it { should be_enabled }
end