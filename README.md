
WARNING: This is pre-alpha software. Use at your own risk until 1.0.

The papermill agent parses responses from your web application.

## Usage Instructions

Papermill works via a middleware called the Collector. 

#### In Rails
    # in config/environment.rb
    config.middleware.use 'Papermill::Collector'

#### In Sinatra/rack
    # in config.ru
    use Papermill::Collector


