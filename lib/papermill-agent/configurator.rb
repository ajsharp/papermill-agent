require 'yaml'

module Papermill

  class Configurator
    attr_writer :environment

    def initialize(config_source = 'config/papermill.yml')
      load_config(config_source)
    end

    def load_config(config_source)
      @config = case
      when config_source.class == String
        YAML.load_file(config_source)
      when config_source.class == Hash
        config_source
      end
    end

    def token
      config['token']
    end

    def endpoint
      if setting('endpoint') && environment != 'production'
        config[environment]['endpoint']
      else
        API_ENDPOINT
      end
    end

    # returns the value of a setting for the current environment or nil, 
    # if it does not exist.
    def setting(name)
      config[environment] && config[environment][name]
    end


    def environment
      @environment ||= (defined?(Rails) && Rails.env) || ENV['RACK_ENV'] || 'development'
    end

    private

    def config
      @config
    end

    def has_config_for_environment?(var)
      config[environment] && config[environment].has_key?(var)
    end
  end
end
