
module Papermill
  module ResponseAdapters

    class Base
      ENV_CAPTURE_FIELDS = [
        'PATH_INFO', 'QUERY_STRING', 'REMOTE_ADDR', 'REMOTE_HOST', 'REQUEST_METHOD',
        'REQUEST_URI', 'SCRIPT_NAME', 'SERVER_NAME', 'SERVER_SOFTWARE', 'HTTP_HOST',
        'HTTP_ACCEPT', 'HTTP_USER_AGENT', 'REQUEST_PATH', 'rack.url_scheme',
        'HTTP_REFERER'
      ]

      attr_reader :status, :headers, :response, :env
      def initialize(status, headers, response, env = {})
        @status, @headers, @response, @env = status, headers, response, env
      end

      def parse
        parsed_response = { :headers => extract_env_info, :status => status }
        # if @status != 304 && @response #&& !@response.body.is_a?(Proc)
        #   parsed_response.merge!(prepare_extra_fields)
        # end
        parsed_response.merge!(additional_response_data)
        Papermill::Storage.store << parsed_response
      end

      private
      def additional_response_data
        {'request_time' => Time.now}
      end

      def extract_env_info
        result_hash = {}

        # Hash#select returns an array in 1.8, so we have to do some manual
        # iteration to extract the key/value pairs from the environment hash.
        ENV_CAPTURE_FIELDS.each { |key| result_hash[key] = env[key] }

        # rename rack.* keys b/c mongo does not allow key names containing a .
        naughty_rack_keys = ENV_CAPTURE_FIELDS.select { |key| key =~ /^rack\./ }
        naughty_rack_keys.each do |key|
          new_key = key.gsub(/^rack\./, '').upcase
          result_hash[new_key] = result_hash.delete(key)
        end
        result_hash
      end

    end

  end
end
