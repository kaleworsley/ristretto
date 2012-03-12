class RemoveNotStaffUsers < ActiveRecord::Migration
  def self.up
    User.find(:all, :conditions => ['users.is_staff <> ?', true]).each(&:destroy)
  end

  def self.down
  end
end
