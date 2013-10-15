#### NGINX  ####
Exec { path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin', '/usr/local/sbin'], }

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
  exec { 'nginx-on boot': command => '/sbin/chkconfig nginx on', require => Class ["nginx::install"], }
}
