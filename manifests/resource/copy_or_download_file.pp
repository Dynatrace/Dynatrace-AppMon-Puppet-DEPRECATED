#copy_or_download_file
define dynatrace::resource::copy_or_download_file(
  $ensure    = 'present',
  $file_name = undef,
  $file_url  = undef,
  $path      = undef
) {
  validate_re($ensure, ['^present$', '^absent$'])
  validate_absolute_path($path)

  if $ensure == present {
    exec { "Check for the presence of ${path}":
      command => '/bin/false',
      returns => 1,
      unless  => "/usr/bin/test -e ${path}"
    }

    if $file_url {
      wget::fetch { "Download ${file_url} to ${path}":
        source      => $file_url,
        destination => $path
      }
    } else {
      file { "Copy ${file_name} to ${path}":
        ensure  => present,
        path    => $path,
        source  => "puppet:///modules/dynatrace/${file_name}",
        require => Exec["Check for the presence of ${path}"]
      }
    }
  }
  else {
    file { $path:
      ensure => 'absent',
    }
  }
}
