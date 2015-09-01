require 'serverspec'

# Required by serverspec
set :backend, :exec

describe file ('/etc/apache2/apache2.conf') do
  its(:content) { should match /^LoadModule dtagent_module "\/opt\/dynatrace\/agent\/lib64\/libdtagent.so"$/ }
end
