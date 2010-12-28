ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'

Bundler.require :default, :test

$:.unshift File.dirname(File.expand_path(__FILE__))
$:.unshift File.dirname(File.expand_path(__FILE__) + '/../lib')

require 'papermill-agent'
require 'fakeweb'

FakeWeb.allow_net_connect = false
FakeWeb.register_uri(:post, Papermill::API_ENDPOINT, {})

RSpec.configure do |config|
  def mock_config_hash
    {'token' => 'mock-token'}
  end

  def agent
    Papermill::Agent.instance
  end

  config.mock_with :rspec
  config.before(:each) do
    # clear the storage before each example
    Papermill::Storage.clear
  end
end
