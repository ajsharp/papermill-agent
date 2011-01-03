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

    context 'when in a production environment' do
      before { agent.config.stub(:environment => 'production') }

      context 'and the storage is empty' do
        before { Storage.clear }

        it 'does not send anything to papermill' do
          agent.should_not_receive(:do_request)
          agent.send_data_to_papermill
        end
      end

      context 'and the storage is not empty' do
        before { Storage.store << ['an item'] }

        it 'sends data to papermill' do
          agent.should_receive(:do_request)
          agent.send_data_to_papermill
        end
      end
    end

    context 'when in a non-production environment' do
      before { agent.config.environment = 'non-production' }

      context 'and there is no config over-ride to log requests in that environment' do
        context 'and the storage is not empty' do
          before { Storage.store << [{:headers => {'Content-Type' => 'text/html'}, :status => 200}] }

          it 'does not send data to papermill' do
            agent.should_not_receive(:do_request)
            agent.send_data_to_papermill
          end
        end

        context 'and the storage is empty' do
          before { Storage.clear }

          it 'does not send data to papermill' do
            agent.should_not_receive(:do_request)
            agent.send_data_to_papermill
          end
        end
      end

      context 'and there is a config over-ride present for that environment' do
        before { agent.config.stub!(:live_mode => true) }

        context 'when the storage is empty' do
          before { Storage.clear }

          it 'sends data to papermill' do
            agent.should_not_receive(:do_request)
            agent.send_data_to_papermill
          end
        end

        context 'when the storage is not empty' do
          before { Storage.store << [{:headers => {'Content-Type' => 'text/html'}, :status => 200}] }

          it 'sends data to papermill' do
            agent.should_receive(:do_request)
            agent.send_data_to_papermill
          end
        end
      end
    end

    context 'when in a production environment' do
      before { agent.config.environment = 'production' }

      context 'by default' do
        context 'when requests have been logged' do
          before { Storage.store << [{:headers => {'Content-Type' => 'text/html'}, :status => 200}] }

          it 'sends request data to the papermill api' do
            agent.should_receive(:do_request)
            agent.send_data_to_papermill
          end
        end

        context 'when no requests have been logged' do
          before { Storage.clear }

          it 'does not send data to papermill' do
            agent.should_not_receive(:do_request)
            agent.send_data_to_papermill
          end
        end
      end

      context 'if a config over-ride is specified to not send data to papermill' do
        before { agent.config.stub!(:live_mode => false) }

        context 'when requests have been logged' do
          before { Storage.store << [{:headers => {'Content-Type' => 'text/html'}, :status => 200}] }

          it 'does not send data to papermill' do
            agent.should_not_receive(:do_request)
            agent.send_data_to_papermill
          end
        end

        context 'when no requests have been logged' do
          before { Storage.clear }

          it 'does not send data to papermill' do
            agent.should_not_receive(:do_request)
            agent.send_data_to_papermill
          end
        end
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
      agent.config.token.should == 'api-key'
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
      before { agent.config.stub!(:environment => 'production') }

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

  describe 'starting the agent' do
    it 'loads the configurator' do
      agent.start
      agent.config.should be_instance_of Configurator
    end
  end

  describe 'disabling the papermill agent' do
    context 'when disabled is set to true' do
      before { agent.disabled = true  }
      after  { agent.disabled = false }

      it 'is disabled' do
        agent.should be_disabled
      end
    end

    context 'wen disabled is set to false' do
      before { agent.disabled = false }

      it 'is disabled' do
        agent.should_not be_disabled
      end
    end

    context 'by default' do
      it 'is not disabled' do
        agent.should_not be_disabled
      end
    end
  end

end

