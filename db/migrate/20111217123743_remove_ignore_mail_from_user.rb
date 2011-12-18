class RemoveIgnoreMailFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :ignore_mail
  end

  def self.down
    add_column :users, :ignore_mail, :text
  end
end
