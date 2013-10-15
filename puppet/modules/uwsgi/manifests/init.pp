#### UWSGI ####
Exec { path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin', '/usr/local/sbin'], }

class uwsgi { include uwsgi::install, uwsgi::conf }

class uwsgi::install { 
  Exec { require => Class ["base::install"], } 
  exec { 'install uwsgi': command => '/usr/bin/pip install uwsgi', onlyif => '/usr/bin/pip list | /bin/grep uwsgi; [ $? -eq 1 ]', }
}

class uwsgi::conf {
  File { require => Class ["uwsgi::install"], owner => "root", group => "root", mode => 644, ensure => file, }
  file { "/etc/uwsgi": ensure => 'directory', }
  file { "/etc/uwsgi/sample-config.ini": mode    => 600, source => 'puppet:///modules/uwsgi/sample-config.ini', require => File['/etc/uwsgi/'], }
}

