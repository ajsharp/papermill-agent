
module Papermill
  module ResponseAdapters

    class Base
      attr_reader :status, :headers, :response, :env
      def initialize(*args)
        @status, @headers, @response, @env = args.flatten
      end

      def parse
        parsed_response = { :headers => headers.merge(env), :status => status }
        # if @status != 304 && @response #&& !@response.body.is_a?(Proc)
        #   parsed_response.merge!(prepare_extra_fields)
        # end
        parsed_response.merge!(additional_response_data)
        Papermill::Storage.store << parsed_response
      end

      private
      def additional_response_data
        {:request_time => Time.now}
      end
    end

  end
end
