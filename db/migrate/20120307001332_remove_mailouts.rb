class RemoveMailouts < ActiveRecord::Migration
  def self.up
    drop_table :mailouts
    drop_table :mailouts_users
  end

  def self.down
    create_table :mailouts do |t|
      t.string :subject
      t.text :body
      t.boolean :sent, :default => false

      t.timestamps
    end

    create_table :mailouts_users, :id => false do |t|
      t.integer :mailout_id
      t.integer :user_id
    end
    add_index :mailouts_users, [:mailout_id, :user_id]
  end
end
