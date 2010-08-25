namespace :user do
  desc "Add a new user. You must supply NAME=, FIRST_NAME=, LAST_NAME=, EMAIL= and PASSWORD=" 
  task :new => :environment do
    if ENV['NAME'] && ENV['FIRST_NAME'] && ENV['LAST_NAME'] && ENV['EMAIL'] && ENV['PASSWORD']
      user = User.create({
        :name => ENV['NAME'],
        :first_name => ENV['FIRST_NAME'],
        :last_name => ENV['LAST_NAME'],
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
      puts "You must supply NAME=, FIRST_NAME=, LAST_NAME=, EMAIL= and PASSWORD="
    end
  end
end
