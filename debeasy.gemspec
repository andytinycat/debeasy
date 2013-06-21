# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'debeasy/version'

Gem::Specification.new do |spec|
  spec.name          = "debeasy"
  spec.version       = Debeasy::VERSION
  spec.authors       = ["Andy Sykes"]
  spec.email         = ["github@tinycat.co.uk"]
  spec.description   = %q{Debeasy is a simple gem that allows you to
                          programmatically read Debian packages with very
                          little effort.}
  spec.summary       = %q{Read .deb (Debian/Ubuntu) packages with ease!}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "libarchive"
end
