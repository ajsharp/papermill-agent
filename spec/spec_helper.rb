ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'

Bundler.require :default, :test

$:.unshift File.dirname(File.expand_path(__FILE__))
$:.unshift File.dirname(File.expand_path(__FILE__) + '/../lib')

require 'papermill-agent'

RSpec.configure do |config|

end
