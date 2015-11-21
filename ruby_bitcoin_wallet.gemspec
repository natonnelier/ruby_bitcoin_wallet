# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby_bitcoin_wallet/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby_bitcoin_wallet"
  spec.version       = RubyBitcoinWallet::VERSION
  spec.authors       = ["Nicolas Tonnelier"]
  spec.email         = ["na.tonnelier@gmail.com"]
  spec.summary       = %q{Ruby methods to interact with Bitcoin blockchain.}
  spec.description   = %q{Main features to allow interaction with Bitcoin blockchain.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end