require 'logger'

module Papermill
  class Logger < ::Logger
    def initialize(io_object = 'log/papermill.log')
      FileUtils.mkdir('log') unless Dir.exists?('log')
      super(io_object)
    end

    def log_exception(exception)
      error(exception.message + exception.backtrace.join("\n"))
    end
  end
end
