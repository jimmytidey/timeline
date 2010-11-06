require 'rcov/rcovtask'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

Rcov::RcovTask.new do |t|

  namespace :rcov do

    task :cucumber => 'db:test:prepare'

    RSpec::Core::RakeTask.new(:rspec) do |t|
       #t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
       #t.spec_files = FileList['spec/**/*_spec.rb']
       t.rcov = true
       t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/}
       t.rcov_opts += %w{--aggregate "coverage/.coverage.data"}
       t.verbose = true
    end
  
    Cucumber::Rake::Task.new(:cucumber) do |t|    
      t.rcov = true
      t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/}
      t.rcov_opts += %w{--aggregate "coverage/.coverage.data"}
    end

    desc "Run both specs and features to generate aggregated coverage"
    task :all do |t|
      @aggregate = true
      rm "coverage/.coverage.data" if File.exist?("coverage/.coverage.data")
      Rake::Task["rcov:rspec"].invoke
      Rake::Task["rcov:cucumber"].invoke
      `chromium-browser #{Rails.root.to_s}/coverage/index.html`
    end

    desc "Run specs in isolation and show report in browser."
    task :r do |t|
      rm "coverage/.coverage.data" if File.exist?("coverage/.coverage.data")
      Rake::Task["rcov:rspec"].invoke
      `chromium-browser #{Rails.root.to_s}/coverage/index.html`
    end

    desc "Run cukes in isolation and show report in browser."
    task :c do |t|
      rm "coverage/.coverage.data" if File.exist?("coverage/.coverage.data")
      Rake::Task["rcov:cucumber"].invoke
      `chromium-browser #{Rails.root.to_s}/coverage/index.html`
    end
  end

end
