class AddIgnoreMailToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :ignore_mail, :text
  end

  def self.down
    remove_column :users, :ignore_mail
  end
end
