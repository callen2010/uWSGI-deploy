#### APPLICATION ####
Exec { path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin', '/usr/local/sbin'], }

class application { include application::install, application::start }

class application::install { 
  File { owner => "root", group => "root", mode => 644, ensure => file, }
  file { "/var/www": ensure => 'directory', }
  file { "/var/www/www.example.com": ensure => 'directory', require => File['/var/www/'], }
  file { "/var/www/www.example.com/sample-application.py": mode    => 600, source => 'puppet:///modules/application/sample-application.py', require => File['/var/www/www.example.com'], }
}

class application::start {
  Exec { require => [ Class ["application::install"], Class ["uwsgi::conf"] ] } 
  exec { 'start uwsgi': command => '/usr/bin/nohup /usr/bin/uwsgi /etc/uwsgi/sample-config.ini &', }
}
