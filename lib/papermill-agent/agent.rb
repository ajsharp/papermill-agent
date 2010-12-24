require 'singleton'
require 'timeout'
require 'json'
require 'restclient'
require 'yaml'

module Papermill

  class Agent
    include Singleton
    
    # send new request data every 10 seconds
    UPDATE_INTERVAL = 10

    attr_reader :last_sent, :mutex, :config, :logger

    # request timeout threshold for sending data to papermill
    @@request_timeout = 5
    def self.request_timeout
      @@request_timeout
    end

    def start
      @last_sent = Time.now
      @mutex     = Mutex.new
      @config    = YAML.load_file('config/papermill.yml')
      @logger    = Logger.new
      Thread.abort_on_exception = true

      @worker_thread = Thread.new do
        loop do
          if time_since_last_sent > UPDATE_INTERVAL
            p "sending #{Storage.store.count} requests to papermill..."
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
        Timeout.timeout(self.class.request_timeout) { do_request unless Storage.store.empty? }
      end
    end

    def do_request
      begin
        logger.info("#{Time.now}: Sending #{Storage.size} requests to papermill")
        RestClient.post API_ENDPOINT, { :token => config['token'], :payload => jsonify_payload }
      rescue RestClient::Exception, Errno::ECONNREFUSED
        p 'transmission error ocurred...'
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
