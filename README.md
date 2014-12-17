# tester

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with tester](#setup)
    * [What tester affects](#what-tester-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with tester](#beginning-with-tester)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Low friction way of working tests into your Puppet module workflow.

## Module Description

tester will install Jenkins and a simple job that will clone a git repo and run
Puppet Lint tests against it. All plugin prerequisites are accounted for.

## Setup

Make sure the rtyler-jenkins module is in your modulepath. The repository containing
the code you want to test needs to have a Rakefile defining the tests you want to run.
I have borrowed the Rakefile from rtyler-jenkins for my use.

    require 'rubygems'
    require 'rake'
    require 'puppetlabs_spec_helper/rake_tasks'
    require 'puppet-lint/tasks/puppet-lint'
    require 'puppet-syntax/tasks/puppet-syntax'
    
    exclude_paths = [
      "pkg/**/*",
      "vendor/**/*",
      "spec/**/*",
      "contrib/**/*"
    ]
    
    # Make sure we don't have the default rake task floating around
    Rake::Task['lint'].clear
    
    PuppetLint.configuration.relative = true
    PuppetLint::RakeTask.new(:lint) do |l|
      l.disable_checks = %w(80chars class_inherits_from_params_class)
      l.ignore_paths = exclude_paths
      l.fail_on_warnings = true
      l.log_format = "FUK %{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
    end
    
    PuppetSyntax.exclude_paths = exclude_paths
    
    task :default => [:lint, :spec, :syntax] 

### What tester affects

* Installs Java and Jenkins via the rtyler-jenkins module.

## Usage

Parameters -

  git_repo           (required) - String. The repository of the module (or modules) you want to test.
  configure_firewall (optional) - Boolean. Set to false if you are not configuring iptables on your host. 
                                  Defaults to true.

## Limitations

Only tested on RHEL 6 and Puppet Enterprise

## Development

Pull requests are welcome at https://www.github.com/robertmaury/puppet-tester
