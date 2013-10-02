#!/bin/sh
echo -e "===== uswg deployment script version 0.1 =====\n"
echo -e "What is the name of the application you are deploying?"
read application_name
read -p "Deploy $application_name now?" -n 1
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\nDeploying $application_name out\n"
else
  echo -e "\nDeclined"
fi

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

cd ~/uswg-deployment-scripts
puppet apply --modulepath modules manifests/sample-mainfest.pp
