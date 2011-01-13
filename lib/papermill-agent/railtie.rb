require 'papermill-agent'
require 'rails'

module Papermill
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'papermill-agent/tasks'
    end

    # initializer "..." do |app|
    #   app.config.middleware.use "Papermill::Collector"
    # end
  end
end
