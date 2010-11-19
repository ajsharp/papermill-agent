
module Papermill

  class ResponseParser
    # ENV_CAPTURE_FIELDS = [
    #   'PATH_INFO', 'QUERY_STRING', 'REMOTE_ADDR', 'REMOTE_HOST', 'REQUEST_METHOD', 
    #   'REQUEST_URI', 'SCRIPT_NAME', 'SERVER_NAME', 'SERVER_SOFTWARE', 'HTTP_HOST', 
    #   'HTTP_ACCEPT', 'HTTP_USER_AGENT', 'REQUEST_PATH'
    # ]

    def self.parse(status, headers, response, env = {})
      klass = if defined?(Rails)
        ResponseAdapters::Rails
      elsif defined?(Sinatra)
        ResponseAdapters::Sinatra
      else
        ResponseAdapters::Base
      end

      klass.new(status, headers, response, env).parse
    end
  end

end
