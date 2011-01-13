require 'papermill-agent'

namespace :papermill do
  desc "Generate a papermill configuration file"
  task :create_config do
    require 'yaml'

    # don't overwrite existing configuration files
    if File.exists?('./config/papermil.yml')
      fail("A papermill configuration file already exists. Please remove it and try again.")
    end

    token = ENV['TOKEN'] || 'replace-with-your-token'

    File.open('./config/papermill.yml', 'w') do |file|
      config = {'token' => token}
      YAML.dump(config, file)
    end
    STDOUT.puts "Your papermill configuration file has been created at config/papermill.yml."
  end
end
