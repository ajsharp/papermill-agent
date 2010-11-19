
$:.unshift File.dirname(File.expand_path(__FILE__))

module Papermill
  autoload :Agent,          'papermill-agent/agent'
  autoload :Collector,      'papermill-agent/rack/collector'
  autoload :ResponseParser, 'papermill-agent/response_parser'
  autoload :Storage,        'papermill-agent/storage'

  module ResponseAdapters
    autoload :Base,    'papermill-agent/response_adapters/base'
    autoload :Rails,   'papermill-agent/response_adapters/rails'
    autoload :Sinatra, 'papermill-agent/response_adapters/sinatra'
  end
end

Papermill::Agent.instance.start
