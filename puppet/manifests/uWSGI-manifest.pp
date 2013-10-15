# cd /vagrant/puppet/manifests/
# puppet apply -v uWSGI-manifest.pp --modulepath=/vagrant/puppet/modules/ --noop
# puppet apply -v uWSGI-manifest.pp --modulepath=/vagrant/puppet/modules/

include base
include uwsgi
include nginx
include application
include motd
