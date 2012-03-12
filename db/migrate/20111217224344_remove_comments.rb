class RemoveComments < ActiveRecord::Migration
  def self.up
    drop_table :comments
  end

  def self.down
    create_table :comments do |t|
      t.text :body
      t.integer :task_id
      t.integer :user_id

      t.timestamps
    end
  end
end