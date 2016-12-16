# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zentool/version'

Gem::Specification.new do |spec|
  spec.name          = 'zentool'
  spec.version       = Zentool::VERSION
  spec.executables   = "zentool"
  spec.authors       = ['Tom Stephen', 'Jared Sharplin', 'Adrian Smith']
  spec.email         = ['tom.stephen@me.com', 'jared.sharplin@uqconnect.edu.au', 'adrian.smith@ennova.com.au']

  spec.summary       = %q{Tool to interface with Zendesk}
  spec.description   = %q{Tool to interface with Zendesk}
  spec.homepage      = 'https://github.com/tomstephen/zentool'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
