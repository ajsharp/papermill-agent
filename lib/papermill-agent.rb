
$:.unshift File.dirname(File.expand_path(__FILE__))

['agent', 'storage', 'collector'].each do |file|
  require "papermill-agent/#{file}"
end

