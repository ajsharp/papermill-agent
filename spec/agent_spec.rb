require 'spec_helper'

module Papermill

  describe 'the agent' do
    it 'has a mutex' do
      Agent.instance.mutex.should be_instance_of Mutex
    end

    context 'when a new process is started' do
      context 'when an agent process does not already exist' do
        it 'should create a new agent process' do
          Papermill::Agent.instance.should be_instance_of Papermill::Agent
        end
      end

      context 'when an agent process already exists' do
        it 'should only allow one agent instance to exist' do
          Papermill::Agent.instance.should eql Papermill::Agent.instance
        end
      end
    end

    context 'when attempting to initialize the agent directly' do
      it 'raises a NoMethodError for attempting to initialize a singleton' do
        lambda {
          Papermill::Agent.initialize
        }.should raise_error(NoMethodError, /private method `initialize' called/)
      end
    end

  end

  describe 'the api endpoint' do
    subject { Agent::API_ENDPOINT }
    it { should == 'http://api.papermillapp.com' }
  end

  describe 'determining the time since the last time data was sent to papermill' do
    before do
      Agent.instance.stub!(:last_sent => Time.mktime(2010, 11, 11, 0, 0, 0))
      Time.stub!(:now => Time.mktime(2010, 11, 11, 0, 0, 9))
    end

    context 'time since the last run' do
      it 'subtracts the current time from @last_sent' do
        Agent.instance.time_since_last_sent.should == 9
      end
    end

    context 'the time until the next run' do
      it 'time until next = interval - time elapsed since last' do
        Agent.instance.seconds_until_next_run.should == 1
      end
    end

  end

  describe 'configuration' do
    it 'provides access to the api token' do
      Agent.instance.config['token'].should == 'api-key'
    end
  end

  describe 'sending data to papermill' do
    before do
      Storage.store << [{:headers => {'Content-Type' => 'text/html'}, :status => 200}]
    end

    it 'jsonifies the payload data' do
      Agent.instance.jsonify_payload.should == '[{"headers":{"Content-Type":"text/html"},"status":200}]'
    end

    it 'empties the store' do
      Agent.instance.jsonify_payload
      Storage.store.should be_empty
    end

    it 'sends a request to the papermill api endpoint' do
      RestClient.should_receive(:post).with(Agent::API_ENDPOINT, :token => 'api-key', :payload => '[{"headers":{"Content-Type":"text/html"},"status":200}]')
      Agent.instance.send_data_to_papermill
    end

    it 'should not send anything if no requests have been stored' do
      Storage.clear
      Agent.should_not_receive(:do_request)
      Agent.instance.send_data_to_papermill
    end
  end

end

