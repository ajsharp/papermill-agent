require 'singleton'
require 'timeout'
require 'json'
require 'restclient'

module Papermill

  class Agent
    include Singleton

    # papermill endpoint which will receive client requests
    API_ENDPOINT = 'http://api.papermillapp.com'
    
    # send new request data every 10 seconds
    UPDATE_INTERVAL = 10

    attr_reader :last_sent, :mutex, :config

    def start
      @last_sent = Time.now
      @mutex     = Mutex.new
      @config    = YAML.load_file('config/papermill.yml')
      Thread.abort_on_exception = true

      @worker_thread = Thread.new do
        loop do
          if time_since_last_sent > 10
            send_data_to_papermill
            @last_sent = Time.now
          end
          sleep_time = seconds_until_next_run
          sleep sleep_time if sleep_time > 0
        end
      end
    end

    def time_since_last_sent
      Time.now - last_sent
    end

    def seconds_until_next_run
      UPDATE_INTERVAL - time_since_last_sent
    end

    def send_data_to_papermill
      begin
        Timeout.timeout(3) { do_request }
      rescue Timeout::Error
        p 'timeout error'
      end
    end

    def do_request
      begin
        RestClient.post API_ENDPOINT, { :api_key => config['token'], :payload => jsonify_payload }
      rescue RestClient::Exception, Errno::ECONNREFUSED
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
