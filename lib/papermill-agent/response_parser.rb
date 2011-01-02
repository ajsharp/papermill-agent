
module Papermill

  class ResponseParser
    def self.parse_klass
      @klass ||= if defined?(Rails)
        ResponseAdapters::Rails
      elsif defined?(Sinatra)
        ResponseAdapters::Sinatra
      else
        ResponseAdapters::Base
      end
    end

    def self.parse(status, headers, response, env = {})
      parse_klass.new(status, headers, response, env).parse
    end
  end

end
