#### SYSTEM WIDE CONFIG ####
Exec { path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin', '/usr/local/sbin'], }
group { 'puppet': ensure => 'present' }

## BASE ##
class base { include epel::repo, base::install, base::conf, base::service }

class epel::repo { 
  Package { provider => rpm, ensure => installed, } 
  package { "epel-release": source => "http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm" }
  exec { 'repo enable': command => 'yum-config-manager --enable epel', }
} 

class base::install {
  Package { require => Class ["epel::repo"], }
  $packagelist = ["sysstat","sendmail","vim-enhanced","git","mlocate","telnet","man","gcc","make","mysql","iftop","python","python-devel","python-pip"] 
  package { $packagelist: ensure => installed, }
  exec { 'timezone set': command => 'ln -sf /usr/share/zoneinfo/EST /etc/localtime', onlyif => 'date | grep EST; [ $? -eq 1 ]', }
  exec { 'hostname change': command => 'echo `cat /etc/hostname`-`date +%D-%T` > /etc/hostname; echo \'127.0.0.1 localhost localhost.localdomain\' `cat /etc/hostname` > /etc/hosts; hostname `cat /etc/hostname`;', require => Exec['timezone set'], onlyif => 'grep "-" /etc/hosts; [ $? -eq 1 ]',}  
  exec { 'set swappiness': command => 'sysctl vm.swappiness=0', onlyif => 'grep 0 /proc/sys/vm/swappiness; [ $? -eq 1 ]', } 
  exec { 'turn off peer dns': command => 'sed -i \'s/PEERDNS=yes/PEERDNS=no/g\' /etc/sysconfig/network-scripts/ifcfg-eth0', onlyif => 'grep \'PEERDNS=no\' /etc/sysconfig/network-scripts/ifcfg-eth0; [ $? -eq 1 ]', } 
  exec { "add search domain": command => "echo 'search example.com' >> /etc/resolv.conf", onlyif => 'grep eaxmple.com /etc/resolv.conf; [ $? -eq 1 ]', }
}

class base::conf {
  File { require => Class ["base::install"], owner => "root", group => "root", mode => 644, ensure => file, }
  file { "/root/.ssh": ensure => 'directory', }
  file { "/root/.ssh/id_rsa": mode    => 600, source => 'puppet:///modules/auth/id_rsa', require => File['/root/.ssh/'], }
} 

class base::service { 
  Service { require => Class ["base::install"], }
  Exec { require => Class ["base::install"], }
  exec { 'updatedb': command => 'updatedb', onlyif => 'locate | grep no', }
  service { "sendmail": ensure => 'running', }
} 

#### UWSGI ####
class uwsgi { include uwsgi::install, uwsgi::conf }

class uwsgi::install { 
  Exec { require => Class ["base::install"], } 
  exec { 'install uwsgi': command => 'pip install uwsgi', onlyif => 'pip list | grep uwsgi; [ $? -eq 1 ]', }
}

class uwsgi::conf {
  File { require => Class ["uwsgi::install"], owner => "root", group => "root", mode => 644, ensure => file, }
  file { "/etc/uwsgi": ensure => 'directory', }
  file { "/etc/uwsgi/sample-config.ini": mode    => 600, source => 'puppet:///modules/uwsgi/sample-config.ini', require => File['/etc/uwsgi/'], }
}

#### APPLICATION ####
class application { include application::install, application::start }

class application::install { 
  File { owner => "root", group => "root", mode => 644, ensure => file, }
  file { "/var/www": ensure => 'directory', }
  file { "/var/www/www.example.com": ensure => 'directory', require => File['/var/www/'], }
  file { "/var/www/www.example.com/sample-application.py": mode    => 600, source => 'puppet:///modules/application/sample-application.py', require => File['/var/www/www.example.com'], }
}

class application::start {
  Exec { require => Class ["application::install"], Class["uswgi::conf"], } 
  exec { 'start uwsgi': command => 'nohup /usr/bin/uwsgi /etc/uwsgi/sample-config.ini &', }
  #exec { 'start uwsgi': command => 'nohup /usr/bin/uwsgi /etc/uwsgi/sample-config.ini', onlyif => 'ps aux | grep sample-config.ini; [ $? -eq 1 ]', }
}


#### NGINX  ####
class nginx { include nginx::install, nginx::conf, nginx::service }

class nginx::install {
  $packagelist = ["nginx"]
  package { $packagelist: ensure => installed }
}

class nginx::conf {
  File { require => Class ["nginx::install"], owner => "nginx", group => "nginx", mode => 644, notify => Class ["nginx::service"], ensure => file, }
  file { "/etc/nginx/nginx.conf": replace => 'yes', source => 'puppet:///modules/nginx/nginx.conf', }
  file { "/etc/nginx/sites-available": ensure => 'directory', require => Package['nginx'] }
  file { "/var/log/www.example.com": ensure => 'directory', require => Package['nginx'] }
  file { "/etc/nginx/sites-enabled": ensure => 'directory', require => Package['nginx'] }
  file { "/etc/nginx/sites-available/www.example.com": source => 'puppet:///modules/nginx/www.example.com', require => File['/etc/nginx/sites-available'], }
  file { '/etc/nginx/sites-enabled/www.example.com': ensure => 'link', notify => Service['nginx'], target => '/etc/nginx/sites-available/www.example.com', }
}

class nginx::service {
  service { "nginx": ensure => "running", require => Class ["nginx::install"], }
  exec { 'nginx-on boot': command => 'chkconfig nginx on', require => Class ["nginx::install"], }
}

include base
include nginx
include uwsgi
include application
