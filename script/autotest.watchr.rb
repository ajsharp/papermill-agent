puts "\n### Watching specs###\n"
 
def cmd() 'bundle exec rspec '; end
 
def run_all_specs
  system(cmd + 'spec/')
end
 
def run_spec(spec)
  if File.exists?(spec)
    system "clear"
    puts "Running #{spec}"
    system(cmd + spec)
  else
    puts "Cannot find spec file #{spec}"
  end
end

watch('^spec\/.*\/.*_spec\.rb') {|md| run_spec(md[0]) }
watch('^spec\/.*_spec\.rb') {|md| run_spec(md[0]) }
watch('^lib/.*\.rb') {|md| run_spec("spec/#{md[1]}_spec.rb") }
watch('^lib/.*\/(.*)\.rb') {|md| run_spec("spec/#{md[1]}_spec.rb") }

# Ctrl-\
Signal.trap('QUIT') do
  puts "\n### Running all specs###\n"
  run_all_specs
end
       
# Ctrl-C
Signal.trap('INT') { abort("\n") }
