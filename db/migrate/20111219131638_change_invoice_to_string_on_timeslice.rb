class ChangeInvoiceToStringOnTimeslice < ActiveRecord::Migration
  def self.up
    change_column(:timeslices, :invoice, :string)
  end

  def self.down
    change_column(:timeslices, :invoice, :integer)
  end
end
