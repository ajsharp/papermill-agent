require 'singleton'
require 'timeout'
require 'json'

# 13 on 517 frenchman st

module Papermill

  class Agent
    include Singleton

    # papermill endpoint which will receive client requests
    API_ENDPOINT = 'http://api.papermillapp.com'
    
    # send new request data every 10 seconds
    UPDATE_INTERVAL = 10

    attr_reader :last_sent

    def mutex
      @mutex ||= Mutex.new
    end

    def config
      @config ||= YAML.load_file('config/papermill.yml')
    end

    def start
      @last_sent = Time.now
      @worker_thread = Thread.new do
        loop do
          if time_since_last_sent > 10
            send_data_to_papermill
            @last_sent = Time.now
          end
        end
      end
    end

    def time_since_last_sent
      Time.now - last_sent
    end

    def send_data_to_papermill
      Timeout.timeout(UPDATE_INTERVAL - 1) do
        api_key = config['token']
        RestClient.post API_ENDPOINT, { :api_key => api_key, :payload => jsonify_payload }
      end
    end

    # Return a json version of the storage array.
    # Also, we'll clear out the storage here
    #
    # TODO: move this to the Storage class.
    def jsonify_payload
      mutex.synchronize do
        json_data = JSON.generate(Storage.store.flatten)
        Storage.clear
        return json_data
      end
    end
  end

end
