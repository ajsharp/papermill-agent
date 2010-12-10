require 'logger'

module Papermill
  class Logger < ::Logger
    def initialize
      FileUtils.mkdir('log') unless Dir.exists?('log')
      super('log/papermill.log')
    end
  end
end