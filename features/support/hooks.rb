# culerity-hooks.rb
Before("@culerity,@celerity") do |scenario|
  unless @env_rvm_jruby
    @env_rvm_jruby = {}
    require 'yaml'
    rvm_info = YAML::load(`bash -l -c 'source ~/.rvm/scripts/rvm; rvm jruby ; rvm info'`)
    rvm_info.first.second['environment'].each do |k, v|
      @env_rvm_jruby[k] = v
    end
    @env_jruby_path = rvm_info.first.second['binaries']['ruby'].gsub(%r{^(.*)/ruby$}, '\1')
  end
  @env_defaults = {}
  @env_rvm_jruby.each do |k, v|
    @env_defaults[k] = ENV[k]
    ENV[k] = v
  end
  @env_path = ENV['PATH']
  ENV['PATH'] = ENV['PATH'] + ":"
end

After("@culerity,@celerity") do |scenario|
  @env_defaults.each do |k, v|
    ENV[k] = v
  end
  ENV["PATH"] = @env_path
end
