class MigrateFirstAndLastNamesToFullNameOnUsers < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      u.full_name = "#{u.first_name} #{u.last_name}"
      u.save
    end
  end

  def self.down
    name = u.full_name.split
    u.first_name = name[0]
    u.last_name = name[1..-1].join(' ')
    u.save
  end
end
