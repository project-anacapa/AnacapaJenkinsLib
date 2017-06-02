# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "anacapa_jenkins_api/version"

Gem::Specification.new do |spec|
  spec.name          = "anacapa_jenkins_api"
  spec.version       = AnacapaJenkinsAPI::VERSION
  spec.authors       = ["garethgeorge", "ncbrown1"]
  spec.email         = ["garethgeorge97@gmail.com", "nickbrown714@gmail.com"]

  spec.summary       = "Provide wrapper around Jenkins API for Project Anacapa"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/project-anacapa/anacapa-jenkins-api"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "jenkins_api_client"
  spec.add_dependency "rest-client"

end
