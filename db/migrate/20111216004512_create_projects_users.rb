class CreateProjectsUsers < ActiveRecord::Migration
  def self.up
    create_table :projects_users, :id => false do |t|
      t.references :project
      t.references :user
    end
    
    add_index :projects_users, [:project_id, :user_id], :uniq => true
  end

  def self.down
    drop_table :projects_users
  end
end
