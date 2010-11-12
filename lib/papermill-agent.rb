
$:.unshift File.dirname(File.expand_path(__FILE__))

module Papermill
  autoload :Agent,          'papermill-agent/agent'
  autoload :Collector,      'papermill-agent/rack/collector'
  autoload :ResponseParser, 'papermill-agent/response_parser'
  autoload :Storage,        'papermill-agent/storage'
end

Papermill::Agent.instance.start
