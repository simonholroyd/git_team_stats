# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_team_stats/version'

Gem::Specification.new do |spec|
  spec.name          = "git_team_stats"
  spec.version       = GitTeamStats::VERSION
  spec.authors       = ["Simon Holroyd"]
  spec.email         = ["sholroyd@gmail.com"]
  spec.description   = %q{git_team_stats is a gem that compiles contribution statistics for projects that span mulitple repos}
  spec.summary       = %q{git_team_stats is a gem that compiles contribution statistics for projects that span mulitple repos}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'json'
  spec.add_dependency 'progress_bar'
  spec.add_dependency 'rainbow'
  spec.add_dependency 'language_sniffer'
  spec.add_dependency 'gli'


end
