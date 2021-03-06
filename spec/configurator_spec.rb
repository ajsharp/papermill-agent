require 'spec_helper'

module Papermill

  describe 'loading the configurator' do
    context 'when a string is passed in' do
      it 'attempts to load the yaml file by that name' do
        YAML.should_receive(:load_file).with('filename')
        Configurator.new('filename')
      end

      context 'the config file does not exist' do
        after { agent.disabled = false }

        it 'disables the agent' do
          lambda {
            Configurator.new('does not exist')
          }.should change(agent, :disabled?).to(true)
        end

        it 'does not raise a file load error' do
          lambda {
            Configurator.new('does not exist')
          }.should_not raise_error(Errno::ENOENT)
        end

        it 'sets config to nil' do
          config = Configurator.new('does not exist')
          config.send(:config).should be_nil
        end
      end

      context 'when no token key is found' do
        it 'disables the agent' do
          lambda {
            Configurator.new({})
          }.should change(agent, :disabled?).to(true)
        end
      end
    end

    context 'when a hash is passed in' do
      it 'uses the hash as the config object' do
        Configurator.new(mock_config_hash).token.should == mock_config_hash['token']
      end
    end

    it 'loads the papermill yaml config file' do
      Configurator.new
    end
  end

  describe 'given a configurator instance' do
    describe 'the token' do
      subject { config.token }

      context 'when the token exists' do
        let(:config) { Configurator.new({'token' => 'token'}) }

        it { should == 'token' }
      end

      context 'when the token does not exist' do
        let(:config) { Configurator.new({}) }

        it { should be_nil }
      end
    end

    describe 'configuring the api endpoint' do
      let(:configurator) { Configurator.new(
        mock_config_hash.merge(
          'test' => {'endpoint' => 'another endpoint'}, 
          'production' => {'endpoint' => 'fake production endpoint'})
        ) 
      }

      context 'for non-production environments' do
        it 'allows the user to over-ride the endpoint' do
          configurator.stub!(:environment => 'test')
          configurator.endpoint.should == 'another endpoint'
        end

        it 'defaults to the api endpoint if nothing else has been specified' do
          configurator.stub!(:environment => 'an undefined env')
          configurator.endpoint.should == Papermill::API_ENDPOINT
        end
      end

      context 'for production environments' do
        before { configurator.stub!(:environment => 'production') }

        it "always sets the endpoint to papermillapp's servers" do
          configurator.endpoint.should == Papermill::API_ENDPOINT
        end

        it 'should be the fake endpoint' do
          configurator.endpoint.should_not == 'fake production endpoint'
        end
      end
    end

    describe 'determining the environment' do
      let(:configurator) { Configurator.new(mock_config_hash) }

      context 'when in a Rails app' do
        before do
          Papermill.class_eval do
            # create a fake rails class
            class Rails
              def self.env; 'rails environment'; end
            end
          end
        end
        # remove the fake rails class
        after { Papermill.class_eval { remove_const(:Rails) } }

        it 'get the environment from rails' do
          configurator.environment.should == 'rails environment'
        end
      end

      context 'when in a rack app' do
        before do
          ENV.stub!(:[]).with('RACK_ENV').and_return('rack env')
        end

        it "gets the environment from ENV['RACK_ENV']" do
          configurator.environment.should == 'rack env'
        end
      end

      context 'not in rails or a rack app' do
        before { ENV['RACK_ENV'] = nil }
        after  { ENV['RACK_ENV'] = 'test' }

        it 'defaults the environment to development' do
          configurator.environment.should == 'development'
        end
      end
    end
  end

  describe 'setting the environment' do
    let(:configurator) { Configurator.new }
    before { configurator.environment = 'some environment' }

    it 'allows manual setting of the envionment' do
      configurator.environment.should == 'some environment'
    end
  end

  describe 'determining whether or not to send data to papermill' do
    context 'for a production environment' do
      let(:config) { Configurator.new }
      before { config.environment = 'production' }

      context 'by default' do
        it 'is true' do
          config.live_mode.should == true
        end
      end

      context 'when a config override is specified with a value of false' do
        let(:config) { Configurator.new({'production' => {'live_mode' => false}}) }

        it 'does not send data to papermill' do
          config.environment.should == 'production'
          config.live_mode.should == false
        end
      end
    end

    context 'for a non-production environment' do
      context 'by default' do
        let(:config) { Configurator.new }
        before { config.environment = 'non-production' }

        it 'is false' do
          config.live_mode.should == false
        end
      end

      context 'when an environment override is specified' do
        let(:config) { Configurator.new('non-production' => {'live_mode' => true}) }
        before { config.environment = 'non-production' }

        it 'uses that setting' do
          config.live_mode.should == true
        end
      end
    end
  end

  describe 'retrieving a setting for the current environment' do
    let(:config) { Configurator.new({'production' => {'my key' => 'my val'}}) }

    context 'for a given environment' do
      before { config.environment = 'production' }

      context 'for a setting that has a value' do
        it 'returns the value of the setting identified by the name' do
          config.setting('my key').should == 'my val'
        end
      end

      context 'for a setting that does not have a value' do
        it 'returns nil' do
          config.setting('does not exist').should == nil
        end
      end
    end

  end
end
