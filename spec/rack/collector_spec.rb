require 'spec_helper'
require 'sinatra'


module Papermill

  describe 'collecting statistics with Collector' do
    def app
      @app ||= Sinatra.new Sinatra::Application do
        get '/' do
          '<html><body>Hello, world!</body></html>'
        end

        use Papermill::Collector
      end
    end

    before do
      request_headers = {'HTTP_USER_AGENT' => 'agent', 'REMOTE_ADDR' => '0.0.0.0', 
        'QUERY_STRING' => 'q=search',
        'SCRIPT_NAME'  => 'my-script',
        'HTTP_ACCEPT'  => 'text/html, application/json',
        'HTTP_HOST'    => 'localhost',
        'REQUEST_URI'  => 'i-requested-this',
        'REMOTE_HOST'  => '123.345.34.2',
        'SERVER_SOFTWARE' => 'apache',
        'HTTP_REFERER' => 'previous url'
      }

      Time.stub(:now => Time.utc(2010, 01, 01))
      @status, @headers, @body = app.call(Rack::MockRequest.env_for('/', request_headers))
    end

    context 'for a 304 response' do
      it 'records the status code'
      it 'doesnt attempt to save any headers'
    end
    
    def last_store
      Storage.store.last
    end

    def headers
      last_store[:headers]
    end

    it 'records the query string' do
      last_store[:status].should == 200
    end

    it 'records request duration'

    it 'records the request time' do
      last_store['request_time'].should == Time.utc(2010, 01, 01)
    end

    it 'records the path info' do
      headers['PATH_INFO'].should == '/'
    end

    it 'records the request uri' do
      headers['REQUEST_URI'].should == 'i-requested-this'
    end

    it 'records the query remote addr' do
      headers['REMOTE_ADDR'].should == '0.0.0.0'
    end

    it 'records the server name' do
      headers['SERVER_NAME'].should == 'example.org'
    end

    it 'records the query string' do
      headers['QUERY_STRING'].should == 'q=search'
    end

    it 'records the request method' do
      headers['REQUEST_METHOD'].should == 'GET'
    end

    it 'records the script name' do
      headers['SCRIPT_NAME'].should == 'my-script'
    end

    it 'records the user agent' do
      headers['HTTP_USER_AGENT'].should == 'agent'
    end

    it 'records the http accept types' do
      headers['HTTP_ACCEPT'].should == 'text/html, application/json'
    end

    it 'records the http host' do
      headers['HTTP_HOST'].should == 'localhost'
    end

    it 'records the server software' do
      headers['SERVER_SOFTWARE'].should == 'apache'
    end

    it 'records the remote host' do
      headers['REMOTE_HOST'].should == '123.345.34.2'
    end

    it 'records the http referrer' do
      headers['HTTP_REFERER'].should == 'previous url'
    end

    it 'does not save any keys with a period in the name' do
      headers.keys.detect { |k| k =~ /\./ }.should == nil
    end

    it 'records the url scheme' do
      headers['URL_SCHEME'].should == 'http'
    end

    context 'for a 304 response' do
      it 'only records certain things'
    end

    context 'for a streamed file response' do
      it 'only records certain things'
    end
  end

end
