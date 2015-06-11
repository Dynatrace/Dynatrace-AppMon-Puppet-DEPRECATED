require 'serverspec'

# Required by serverspec
set :backend, :exec

describe file ('/etc/apache2/apache2.conf') do
  its(:content) { should match /^LoadModule dtagent_module "\/opt\/dynatrace\/agent\/lib64\/libdtagent.so"$/ }
end

describe file ('/etc/init.d/apache2') do
  its(:content) { should match /^# Required-Start:.*? dynaTraceWebServeragent$/ }
end

describe file ('/etc/init.d/apache2') do
  its(:content) { should match /^# Required-Stop:.*? dynaTraceWebServeragent$/ }
end
