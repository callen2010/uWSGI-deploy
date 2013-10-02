#!/bin/sh
echo -e "===== uwsgi deployment script version 0.1 =====\n"

# RDEVEL, IRB, RDOC, RUBYGEMS
/usr/bin/yum -y install ruby-devel ruby-irb ruby-rdoc rubygems

# FACTER
/usr/bin/wget http://puppetlabs.com/downloads/facter/facter-latest.tgz
/bin/tar -xf facter-latest.tgz
cd facter-*
ruby install.rb
rm -rf facter-*

# PUPPET
/usr/bin/wget http://puppetlabs.com/downloads/puppet/puppet-latest.tgz
/bin/tar -xf puppet-latest.tgz
cd puppet-*
ruby install.rb
rm -rf puppet-*

cd ~/uWSGI-deploy
puppet apply --modulepath modules manifests/sample-mainfest.pp
