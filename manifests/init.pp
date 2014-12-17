# Installs Jenkins via rtyler/jenkins module, with all plugins necessary
# to run Puppet Lint tests against a module in Git. The repo can be defined
# in the git_repo parameter.

class tester (
  $git_repo = undef,
  $configure_firewall = true,
  ) {

  $plugins = [
    'promoted-builds',
    'matrix-project',
    'scm-api',
    'credentials',
    'mailer',
    'parameterized-trigger',
    'ssh-credentials',
    'git-client',
    'token-macro',
    'git',
    'maven-plugin', # I probably don't need this
    'analysis-core',
    'violations',
    'dashboard-view',
    'warnings',
    'rake'
    ]


# Allow time for the Jenkins service to come up completely
  Service <| title == 'jenkins' |> {
    hasrestart => true,
    restart    => '/etc/init.d/jenkins restart && sleep 20',
    start      => '/etc/init.d/jenkins start && sleep 20',
  }

  if $::is_pe {
    $gem_provider = 'pe_gem'

    file { '/usr/bin/rake':
      target => '/opt/puppet/bin/rake',
    }
  } else {
    $gem_provider = 'gem'
  }

  package { ['puppet-lint','puppet-syntax']:
    ensure   => present,
    provider => $gem_provider,
  }

  class { 'jenkins':
    configure_firewall => $configure_firewall,
  }

  jenkins::plugin { $plugins: }

  jenkins::job { 'puppet':
    config  => template('tester/config.xml.erb'),
  }

}
