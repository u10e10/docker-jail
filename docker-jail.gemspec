# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docker-jail/version'

Gem::Specification.new do |spec|
  spec.name          = "docker-jail"
  spec.version       = DockerJail::VERSION
  spec.authors       = ['u+']
  spec.email         = ['uplus.e10@gmail.com']

  spec.summary       = %q{Easy run commands in docker jail}
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/uplus/docker-jail'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.3.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'docker-api'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'yard'
end
