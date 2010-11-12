
The papermill agent parses responses from your web application.

It gathers the status and headers from each and every response rendered by 
your app. Additionally, you can configure the agent to save other types
of arbitrary data:

Papermill::Collector.new :fields => {:email => lambda { User.find('session_key') }}
