Gem::Specification.new do |s|
  s.name          = 'mismatch-inspectable'
  s.version       = '0.1.0'
  s.authors       = ['Tyler Rhodes']
  s.email         = ['tyler.rhodes@aya.yale.edu']
  s.summary       = 'A library for easily printing and debugging mismatched values'
  s.description   = 'A library that includes a module that can print mismatched values for any class that includes it. Supports recursive inspection of nested objects.'
  s.homepage      = 'https://github.com/tyleCaineRhodes/mismatch-inspectable'
  s.licenses       = ['MIT']

  s.files        = Dir['{lib,spec}/**/*', 'README.md', 'LICENSE.md']
  s.test_files   = Dir['spec/**/*']
  s.require_paths = ['lib']
  s.add_development_dependency 'rspec'
end
