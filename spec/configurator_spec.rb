require 'spec_helper'

module Papermill

  describe 'loading the configurator' do
    context 'when a string is passed in' do
      it 'attempts to load the yaml file by that name' do
        YAML.should_receive(:load_file).with('filename')
        Configurator.new('filename')
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
    let(:configurator) do
      YAML.stub!(:load_file).and_return({'token' => 'token'})
      Configurator.new 
    end

    describe 'the token' do
      it 'should return the token from the config' do
        configurator.token.should == 'token'
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


end
