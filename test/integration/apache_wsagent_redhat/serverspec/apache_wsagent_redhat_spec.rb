require 'serverspec'

# Required by serverspec
set :backend, :exec

describe file ('/etc/httpd/conf/httpd.conf') do
  its(:content) { should match /^LoadModule dtagent_module "\/opt\/dynatrace\/agent\/lib64\/libdtagent.so"$/ }
end
