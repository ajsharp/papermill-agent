require 'singleton'
require 'timeout'

module Papermill

  class Agent
    include Singleton
    
    # send new request data every 10 seconds
    UPDATE_INTERVAL = 10

    def start
      connect!

      @worker_thread = Thread.new do
        while should_run? do
          # start collecting request data
        end
      end
    end

    def connect!

    end    
  end

end
