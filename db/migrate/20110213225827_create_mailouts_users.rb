class CreateMailoutsUsers < ActiveRecord::Migration
  def self.up
    create_table :mailouts_users, :id => false do |t|
      t.integer :mailout_id
      t.integer :user_id
    end
    add_index :mailouts_users, [:mailout_id, :user_id]
  end

  def self.down
    drop_table :mailouts_users
  end
end
