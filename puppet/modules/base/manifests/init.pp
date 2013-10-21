#### SYSTEM WIDE CONFIG ####
Exec { path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin', '/usr/local/sbin'], }
group { 'puppet': ensure => 'present' }

## BASE ##
class base { include epel::repo, base::install, base::conf, base::service }

class epel::repo { 
  package { "yum-utils":
    ensure => "installed",
    before => Exec["repo enable"],
  }
  package { "epel-release": source => "http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm", provider => rpm, ensure => installed, }
  exec { 'repo enable': command => '/usr/bin/yum-config-manager --enable epel' }
} 

class base::install {
  Package { require => Class ["epel::repo"], }
  $packagelist = ["sysstat","sendmail","vim-enhanced","git","mlocate","telnet","man","gcc","make","mysql","iftop","python","python-devel","python-pip"] 
  package { $packagelist: ensure => installed, }
  exec { 'timezone set': command => '/bin/ln -sf /usr/share/zoneinfo/EST /etc/localtime', onlyif => '/bin/date | /bin/grep EST; [ $? -eq 1 ]', }
  exec { 'hostname change': command => '/bin/echo admin-`date +%D-%T` > /etc/hostname; /bin/echo \'127.0.0.1 localhost localhost.localdomain\' `cat /etc/hostname` > /etc/hosts; hostname `cat /etc/hostname`;', require => Exec['timezone set'], onlyif => '/bin/grep "-" /etc/hosts; [ $? -eq 1 ]',}  
  exec { 'set swappiness': command => '/sbin/sysctl vm.swappiness=0', onlyif => '/bin/grep 0 /proc/sys/vm/swappiness; [ $? -eq 1 ]', } 
  exec { "add search domain": command => "/bin/echo 'search example.com' >> /etc/resolv.conf", onlyif => '/bin/grep eaxmple.com /etc/resolv.conf; [ $? -eq 1 ]', }
}

class base::conf {
  File { require => Class ["base::install"], owner => "root", group => "root", mode => 644, ensure => file, }
  file { "/root/.ssh": ensure => 'directory', }
} 

class base::service { 
  Service { require => Class ["base::install"], }
  Exec { require => Class ["base::install"], }
  exec { 'updatedb': command => '/usr/bin/updatedb', onlyif => '/usr/bin/locate | /bin/grep no', }
  service { "sendmail": ensure => 'running', }
} 

