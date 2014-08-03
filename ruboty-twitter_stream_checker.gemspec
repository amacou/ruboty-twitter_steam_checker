# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruboty/twitter_stream_checker/version'

Gem::Specification.new do |spec|
  spec.name          = "ruboty-twitter_stream_checker"
  spec.version       = Ruboty::TwitterStreamChecker::VERSION
  spec.authors       = ["amacou"]
  spec.email         = ["amacou.abf@gmail.com"]
  spec.summary       = %q{ruboty twitter tream check plugin}
  spec.description   = %q{ruboty twitter tream check plugin}
  spec.homepage      = "http://github.com/amacou/ruboty-twitter_stream_checker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "ruboty"
  spec.add_dependency "tweetstream"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
