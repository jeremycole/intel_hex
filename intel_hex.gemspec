# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require "intel_hex/version"

Gem::Specification.new do |s|
  s.name        = "intel_hex"
  s.version     = IntelHex::VERSION
  s.summary     = "Parser for Intel hex files"
  s.license     = "BSD-3-Clause"
  s.description = "An Intel hex file parser for (e.g. AVR) working with firmware files"
  s.authors     = ["Jeremy Cole"]
  s.email       = "jeremy@jcole.us"
  s.homepage    = "https://github.com/jeremycole/intel_hex"
  s.files = Dir.glob("{bin,lib}/**/*") + %w[LICENSE.md README.md]
  s.executables = %w[intel_hex_reader]
  s.require_path = "lib"

  s.required_ruby_version = ">= 2.6", "< 4"

  s.add_development_dependency("rspec")
  s.add_development_dependency("rubocop")
  s.add_development_dependency("rubocop-rspec")
  s.metadata["rubygems_mfa_required"] = "true"
end
