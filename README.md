uWSGI-Deploy
=======================

Sample deployment config for uwsgi, installing a hello world application, with nginx as a front end (using puppet)

INSTRUCTIONS: This has been tested on Amazon Linux AMI 2013.09


   * Install Git

      * yum install git-core

   * Change the hostname of the server (this can be anything)

      * hostname 01; echo "01" > /etc/hostname

   * Clone uWSGI-deploy

      * git clone git@github.com:callen2010/uWSGI-deploy.git

   * Execute deploy.sh

      * uWSGI-deploy/deploy.sh

