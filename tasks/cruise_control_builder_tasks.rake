####### Crap from rspec to properly load their spec task >>>
rspec_gem_dir = nil
Dir["#{RAILS_ROOT}/vendor/gems/*"].each do |subdir|
  rspec_gem_dir = subdir if subdir.gsub("#{RAILS_ROOT}/vendor/gems/","") =~ /^(\w+-)?rspec-(\d+)/ && File.exist?("#{subdir}/lib/spec/rake/spectask.rb")
end
rspec_plugin_dir = File.expand_path(File.dirname(__FILE__) + '/../../vendor/plugins/rspec')

if rspec_gem_dir && (test ?d, rspec_plugin_dir)
  raise "\n#{'*'*50}\nYou have rspec installed in both vendor/gems and vendor/plugins\nPlease pick one and dispose of the other.\n#{'*'*50}\n\n"
end

if rspec_gem_dir
  $LOAD_PATH.unshift("#{rspec_gem_dir}/lib")
elsif File.exist?(rspec_plugin_dir)
  $LOAD_PATH.unshift("#{rspec_plugin_dir}/lib")
end

# Don't load rspec if running "rake gems:*"
unless ARGV.any? {|a| a =~ /^gems/}

require 'spec/rake/spectask'
####### <<< Crap from rspec to properly load their spec task

namespace :spec do
  desc "Run the specs with ant output"
  task :ant => 'db:test:prepare'
  Spec::Rake::SpecTask.new('ant') do |t|
    t.spec_opts = %W[--require #{File.dirname(__FILE__)}/../lib/rspec_junit_formatter.rb --format JUnitFormatter:log/test-cc.log]
  end
end

namespace :build do
  desc "Run the ant build task"
  task :ant => ['gems:install', 'db:migrate:zero', 'db:migrate', 'spec:ant']
end

namespace :db do
  namespace :migrate do
    desc "Migrate to version 0"
    task :zero => :environment do
      ActiveRecord::Migrator.migrate("db/migrate/", 0)
    end
  end
end

end
