# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epaybg/version'

Gem::Specification.new do |gem|
  gem.name          = 'epaybg'
  gem.version       = Epaybg::VERSION
  gem.authors       = ['gmitrev']
  gem.email         = ['gvmitrev@gmail.com']
  gem.description   = 'Gem for dealing with epay.bg payments.'
  gem.summary       = 'Epaybg provides integration with the epay.bg payment services. It supports payments through epay.bg, credit cards and in EasyPay offices. '
  gem.homepage      = 'http://github.com/gmitrev/epaybg'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'activesupport'
end
