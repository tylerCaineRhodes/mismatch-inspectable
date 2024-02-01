require_relative "lib/mismatch_inspectable/version"

Gem::Specification.new do |s|
  s.name          = "mismatch-inspectable"
  s.version       = MismatchInspectable::VERSION
  s.authors       = ["Tyler Rhodes"]
  s.email         = ["tyler.rhodes@aya.yale.edu"]
  s.summary       = "A library for easily printing and debugging mismatched values"
  s.description   = "A library that includes a module that can print mismatched
  values for any class that includes it. Supports recursive inspection of nested
  objects."
  s.homepage = "https://github.com/tyleCaineRhodes/mismatch-inspectable"
  s.licenses = ["MIT"]
  s.required_ruby_version = ">= 3.2.1"

  s.files = Dir["{lib,spec}/**/*", "README.md", "LICENSE.md"]
  s.require_paths = ["lib"]
  s.metadata["rubygems_mfa_required"] = "true"
end
