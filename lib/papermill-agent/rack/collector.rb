
module Papermill

  # The Collector class is the middleware component of papermill.
  # To use it with a rails app, you must add the following to
  # your environment.rb file:
  #
  # config.middleware.use Papermill::Collector
  class Collector
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)
      ResponseParser.parse(status, headers, response, env)
      [status, headers, response]
    end
  end

end
