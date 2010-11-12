require 'spec_helper'
require 'sinatra'

class MockApp < Sinatra::Base
  get '/' do
    '<html><body>Hello, world!</body></html>'
  end
end

module Papermill

  describe 'parsing a response' do
    let(:valid_response) { [200, {'Content-Type' => 'text/html'}, []] }
    def do_request
      request = Rack::MockRequest.new(MockApp)
      request.get('/')
    end

    def store
      Storage.store.last
    end

    it "adds the parsed response to papermill's storage mechanism" do
      lambda { 
        ResponseParser.parse(*valid_response)
      }.should change(Papermill::Storage.store, :count).by(1)
    end

    it "extracts the status code" do
      ResponseParser.parse(*valid_response)
      store[:status].should == 200
    end

    it "extracts the headers" do
      ResponseParser.parse(*valid_response)
      store[:headers].should == {'Content-Type' => 'text/html'}
    end
  end

end
