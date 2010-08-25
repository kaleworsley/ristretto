# Creates a task to support seed fixtures for your production system.
# - Store this file in lin/tasks/seed_fixtures.rake
# - Place fixtures in db/seed.
# - Use with 'rake db:seed'

namespace :db do
  desc "Loads seed fixtures into your database." 
  task :seed => :environment do
    require 'active_record/fixtures'
    seed_dir_rel = File.join('db', 'seed')
    seed_dir_abs = File.join(RAILS_ROOT, seed_dir_rel)
    
    # Supported formats are YAML and CSV
    Dir.glob(File.join(seed_dir_abs, '*.{yml,csv}')).each do |file|      
      Fixtures.create_fixtures(seed_dir_rel, File.basename(file, '.*'))
    end
  end
end
