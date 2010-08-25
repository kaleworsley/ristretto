namespace :user do
  desc "Add a user to staff. Use with either EMAIL= or NAME= to select the user" 
  task :is_staff => :environment do

    if ENV['EMAIL']
      user = User.find_by_email!(ENV['EMAIL'])
    elsif ENV['NAME']
      user = User.find_by_name!(ENV['NAME'])
    else
      puts "Use either NAME=username or EMAIL=email@domain.com to specify user"
    end

    user.update_attribute(:is_staff, true)
    puts "Added #{user} to staff"
  end
end
