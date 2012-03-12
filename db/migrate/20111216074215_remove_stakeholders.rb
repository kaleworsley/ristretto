class RemoveStakeholders < ActiveRecord::Migration
  def self.up
    drop_table :stakeholders
  end

  def self.down
    create_table :stakeholders do |t|
      t.integer :user_id
      t.integer :project_id
      t.text :role

      t.timestamps
    end
  end
end
