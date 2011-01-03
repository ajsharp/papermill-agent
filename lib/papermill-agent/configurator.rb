require 'yaml'

module Papermill

  class Configurator
    attr_writer :environment

    def initialize(config_source = 'config/papermill.yml')
      load_config(config_source)
      after_init
    end

    # Loads the papermill configuration.
    #
    # By default, the papermill configuration is read from a yaml file located
    # at ./config/papermill.yml. Still, the configuration source can either be
    # a yaml file of any name or a ruby hash.
    #
    # If the configuration file cannot be found, the agent will be disabled.
    def load_config(config_source)
      @config = case
      when config_source.class == String
        begin
          YAML.load_file(config_source)
        rescue Errno::ENOENT => e
          disable_agent
          Agent.instance.logger.info "The papermill configuration file does not exist. The papermill agent is disabled."
          return nil
        end
      when config_source.class == Hash
        config_source
      end
    end

    def token
      (config && config.has_key?('token')) ? config['token'] : nil
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

    def live_mode
      if has_config_for_environment?('live_mode')
        setting('live_mode')
      else
        # default to true for production environments, false otherwise
        environment == 'production' ? true : false
      end
    end

    def environment
      @environment ||= (defined?(Rails) && Rails.env) || ENV['RACK_ENV'] || 'development'
    end

    private
    # If there is no token, disable the agent.
    def after_init
      if token.nil?
        disable_agent
      end
    end

    def disable_agent
      Agent.instance.disabled = true
    end

    # holds the internal config hash
    def config
      @config
    end

    def has_config_for_environment?(var)
      config[environment] && config[environment].has_key?(var)
    end
  end
end
