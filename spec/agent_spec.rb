require 'spec_helper'

module Papermill

  describe 'the agent' do
    it 'has a mutex' do
      agent.mutex.should be_instance_of Mutex
    end

    context 'when a new process is started' do
      context 'when an agent process does not already exist' do
        it 'should create a new agent process' do
          Agent.instance.should be_instance_of Papermill::Agent
        end
      end

      context 'when an agent process already exists' do
        it 'should only allow one agent instance to exist' do
          Agent.instance.should eql Papermill::Agent.instance
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
    subject { Papermill::API_ENDPOINT }
    it { should == 'http://api.papermillapp.com' }
  end

  describe 'request timeout interval' do
    it 'defaults to 5 seconds' do
      Agent.request_timeout.should == 5
    end
  end

  describe 'determining the time since the last time data was sent to papermill' do
    before do
      agent.stub!(:last_sent => Time.mktime(2010, 11, 11, 0, 0, 0))
      Time.stub!(:now => Time.mktime(2010, 11, 11, 0, 0, 9))
    end

    context 'time since the last run' do
      it 'subtracts the current time from @last_sent' do
        agent.time_since_last_sent.should == 9
      end
    end

    context 'the time until the next run' do
      it 'time until next = interval - time elapsed since last' do
        agent.seconds_until_next_run.should == 1
      end
    end
  end

  describe 'configuration' do
    it 'provides access to the api token' do
      agent.config['token'].should == 'api-key'
    end
  end

  describe 'given a logged request' do
    before do
      Storage.store << [{:headers => {'Content-Type' => 'text/html'}, :status => 200}]
    end

    describe 'serializing the payload' do
      it 'jsonifies the payload data' do
        agent.jsonify_payload.should == '[{"headers":{"Content-Type":"text/html"},"status":200}]'
      end
    end

    describe 'sending data to papermill' do
      it 'empties the store' do
        agent.send_data_to_papermill
        Storage.store.should be_empty
      end

      it 'sends a request to the papermill api endpoint' do
        RestClient.should_receive(:post).with(Papermill::API_ENDPOINT, :token => 'api-key', :payload => '[{"headers":{"Content-Type":"text/html"},"status":200}]')
        agent.send_data_to_papermill
      end

      it 'does not send anything if no requests have been stored' do
        Storage.clear
        Agent.should_not_receive(:do_request)
        agent.send_data_to_papermill
      end

      it 'logs a message to the logger' do
        agent.logger.should_receive(:info).with(/Sending 1 requests to papermill/)
        agent.send_data_to_papermill
      end
    end

  end

  describe 'the logger' do
    before { agent.start }

    it 'has a logger' do
      agent.logger.should be_instance_of Papermill::Logger
    end
  end

end

