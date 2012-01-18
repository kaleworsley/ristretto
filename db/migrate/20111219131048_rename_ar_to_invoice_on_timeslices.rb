class RenameArToInvoiceOnTimeslices < ActiveRecord::Migration
  def self.up
    rename_column :timeslices, :ar, :invoice
  end

  def self.down
    rename_column :timeslices, :invoice, :ar
  end
end
