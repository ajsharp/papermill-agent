require 'singleton'
require 'timeout'
require 'json'
require 'restclient'

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
      @config    = Configurator.new
      @logger    = Logger.new
      logger.info "\n\n=============== Starting papermill-agent at #{Time.now} in process #{Process.pid}"
      Thread.abort_on_exception = true

      @worker_thread = Thread.new do
        loop do
          if time_since_last_sent > UPDATE_INTERVAL
            send_data_to_papermill
            @last_sent = Time.now
          end
          sleep_time = seconds_until_next_run
          sleep sleep_time if sleep_time > 0
        end
      end
    end

    def send_data_to_papermill
      begin
        Timeout.timeout(config.setting('request_timout') || self.class.request_timeout) do
          do_request if !Storage.empty? && config.live_mode
        end
      rescue Timeout::Error => e
        logger.log_exception(e)
      end
    end

    def do_request
      begin
        logger.info("#{Time.now}: Sending #{Storage.size} requests to papermill")
        RestClient.post config.endpoint, { :token => config.token, :payload => jsonify_payload }
        Storage.clear
      rescue RestClient::Exception, Errno::ECONNREFUSED, SocketError => e
        logger.log_exception e
      end
    end

    def time_since_last_sent
      Time.now - last_sent
    end

    def seconds_until_next_run
      UPDATE_INTERVAL - time_since_last_sent
    end

    # Return a json version of the storage array.
    # Also, we'll clear out the storage here
    #
    # TODO: move this to the Storage class.
    def jsonify_payload
      mutex.synchronize do
        begin
          json_data = Storage.store.flatten.to_json
        rescue => e
          logger.log_exception(e)
        end
        return json_data
      end
    end
  end

end
