namespace :user do
  desc "Add a new user. You must supply NAME=, EMAIL= and PASSWORD="
  task :new => :environment do
    if ENV['NAME'] && ENV['EMAIL'] && ENV['PASSWORD']
      user = User.create({
        :full_name => ENV['NAME'],
        :email => ENV['EMAIL'],
        :password => ENV['PASSWORD'],
        :password_confirmation => ENV['PASSWORD'],
      })
      if user.save
        puts "Added #{user}."
      else
        puts user.errors.full_messages
      end
    else
      puts "You must supply NAME=, EMAIL= and PASSWORD="
    end
  end
end
