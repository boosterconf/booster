task :test do
  puts "Starting specs"
  system('bundle exec rake spec')
end