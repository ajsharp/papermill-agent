
WARNING: This is pre-alpha software. Use at your own risk until 1.0.

The papermill agent parses responses from your web application.

# Installation #

## Step 1: Create config/papermill.yml ##

Papermill's configuration information is stored in a yml file located at 
`[PROJECT_ROOT]/config/papermill.yml`. The only required configuration
option is your api token:

    # config/papermill.yml
    token: you-api-token
    
## Step 2: include the middleware layer for request capturing and logging ##

Papermill works by capturing every request submitted to your application and 
periodically sending them off to the PapermillApp servers. To enable this,
you must add the Papermill middleware class to your application's middleware
stack.

In rails, this is done in either `config/environment.rb` or `config/application.rb`,
depending on whether you're using rails 2 or rails 3. In a sinatra or rack app,
you simply add the middleware via rack's `use` method.

See the examples below.

### rails 2.x ###
    # in config/environment.rb
    config.middleware.use 'Papermill::Collector'

### rails 3 ###
    # in config/application.rb
    config.middleware.use 'Papermill::Collector'

### sinatra or a rack application ###
    # in config.ru or in a Rack::Builder stack
    use Papermill::Collector


