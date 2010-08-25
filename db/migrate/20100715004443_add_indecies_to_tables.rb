class AddIndeciesToTables < ActiveRecord::Migration
  def self.up
    add_index(:tasks, :project_id)
    add_index(:tasks, :assigned_to_id)
    add_index(:tasks, :user_id)
    add_index(:projects, :customer_id)
    add_index(:projects, :user_id)
    add_index(:timeslices, :user_id)
    add_index(:timeslices, :task_id)
    add_index(:comments, :user_id)
    add_index(:comments, :task_id)
  end
  def self.down
    remove_index(:tasks, :project_id)
    remove_index(:tasks, :assigned_to_id)
    remove_index(:tasks, :user_id)
    remove_index(:projects, :customer_id)
    remove_index(:projects, :user_id)
    remove_index(:timeslices, :user_id)
    remove_index(:timeslices, :task_id)
    remove_index(:comments, :user_id)
    remove_index(:comments, :task_id)
  end
end
