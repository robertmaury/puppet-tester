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



  Service <| title == 'jenkins' |> {
    hasrestart => true,
    restart    => 'service jenkins restart && while true; do \
      java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 \
      version && break; sleep 5; done',
    start      => 'service jenkins start && while true; do \
      java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 \
      version && break; sleep 5; done',
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
