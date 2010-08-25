class CreateStakeholders < ActiveRecord::Migration
  def self.up
    create_table :stakeholders do |t|
      t.integer :user_id
      t.integer :project_id
      t.text :role

      t.timestamps
    end
  end

  def self.down
    drop_table :stakeholders
  end
end
