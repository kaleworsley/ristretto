class CreateMailouts < ActiveRecord::Migration
  def self.up
    create_table :mailouts do |t|
      t.string :subject
      t.text :body
      t.boolean :sent, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :mailouts
  end
end
