Gem::Specification.new do |spec|
  spec.name          = 'mismatch-inspectable'
  spec.version       = '0.1.0'
  spec.authors       = ['Tyler Rhodes']
  spec.email         = ['tyler.rhodes@aya.yale.edu']
  spec.summary       = 'A library for easily printing and debugging mismatched values'
  spec.description   = 'A library that includes a module that can print mismatched values for any class that includes it. Supports recursive inspection of nested objects.'
  spec.homepage      = 'https://github.com/your-username/mismatch-inspectable'
  spec.license       = 'MIT'

  spec.files         = [
    'lib/mismatch_inspectable.rb'
  ]
  spec.require_paths = ['lib']
  spec.add_development_dependency 'rspec'
end
