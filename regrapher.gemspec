# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'regrapher/version'

Gem::Specification.new do |s|
  s.name = 'regrapher'
  s.version = Regrapher::VERSION
  s.license = 'MIT'

  s.authors = ['Ramzi Ben Salah']
  s.email = ['ramzi.salah@gmail.com']

  s.files = Dir.glob('{bin,lib}/**/*') + %w(Rakefile README.md)
  s.test_files = Dir.glob('spec/**/*')
  s.homepage = 'http://github.com/regrapher/regrapher'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.summary = 'Regrapher logger for ruby'
  s.description = 'Provides convenience logger to format events and metric values in the regrapher format'

  s.required_ruby_version = '>= 1.9.3'

  s.add_development_dependency 'rake', '~> 11.1'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'timecop', '~> 0.8'
end
