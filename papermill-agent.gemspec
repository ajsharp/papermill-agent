# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "papermill-agent"
  s.version = '0.0.1'
  s.platform = Gem::Platform::RUBY
  s.authors = ["Alex Sharp"]
  s.email = ["ajsharp@gmail.com"]
  s.homepage = "http://github.com/ajsharp/papermill-agent"
  s.summary = "Client agent for papermillapp.com"
  s.description = "Client agent for papermillapp.com"

  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = Dir.glob(["lib/**/*"]) + %w(LICENSE README.md)
  s.require_paths = ["lib"]
  s.executables = []
  s.test_files = Dir.glob(['spec/**/*'])
end

