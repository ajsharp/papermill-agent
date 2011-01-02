# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "papermill-agent"
  s.version = '0.0.2'
  s.platform = Gem::Platform::RUBY
  s.authors = ["Alex Sharp"]
  s.email = ["ajsharp@gmail.com"]
  s.homepage = "http://github.com/ajsharp/papermill-agent"
  s.summary = "The client agent for papermillapp.com"
  s.description = "The client agent for papermillapp.com"
  s.add_runtime_dependency("rest-client", ["~>1.6.1"])

  s.extra_rdoc_files = [
    "README.md",
    "doc/ideas.md"
  ]
  s.files = Dir.glob(["lib/**/*"]) + %w(LICENSE README.md config/papermill.sample.yml Gemfile Rakefile)
  s.require_paths = ["lib"]
  s.executables = []
  s.test_files = Dir.glob(['spec/**/*'])
end

