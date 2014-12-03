# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db_replicator/version'

Gem::Specification.new do |spec|
  spec.name          = 'db_replicator'
  spec.version       = DbReplicator::VERSION
  spec.authors       = ['Michael Eatherly']
  spec.email         = ['meatherly@gmail.com']
  spec.summary       = ''
  spec.description   = ''
  spec.homepage      = 'https://github.com/meatherly/db_replicator'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'generator_spec', '~> 0'
  spec.add_development_dependency 'rspec', '>= 3'
  spec.add_development_dependency 'rubocop', '~> 0'
  spec.add_runtime_dependency 'sequel', '>= 4.15.0'
  spec.add_runtime_dependency 'ruby-progressbar', '~> 1.6.1'
  spec.add_runtime_dependency 'rails', '>= 3'
  spec.add_runtime_dependency 'colorize'

  spec.add_dependency 'net-ssh'
  spec.add_dependency 'net-scp'

  spec.required_ruby_version = '~> 2.0'

end
