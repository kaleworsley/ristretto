class CreateTimeslices < ActiveRecord::Migration
  def self.up
    create_table :timeslices do |t|
      t.text :description
      t.integer :task_id
      t.datetime :started
      t.datetime :finished
      t.boolean :chargeable

      t.timestamps
    end
  end

  def self.down
    drop_table :timeslices
  end
end
