class Ticket < ActiveRecord::Base
  belongs_to :ticketable, :polymorphic => true
  has_many :timeslices, :as => :timetrackable, :dependent => :destroy  
  
  accepts_nested_attributes_for :timeslices
    
  def ticketable_object
    "#{ticketable_type}|#{ticketable_id}"
  end
  
  def ticketable_object=(str)
    split = str.split('|')
    self.ticketable_type= split[0]
    self.ticketable_id= split[1]
  end
  
  def name
    description.split("\n")[0]
  end
  
  def timetrackable_object
    "Ticket|#{id}"
  end
  
  def to_option
    if ticketable.class.to_s == 'Customer'
      ["#{ticketable.name} : #{name}", timetrackable_object]
    elsif ticketable.class.to_s == 'Project'
      ["#{ticketable.customer.name} - #{ticketable.name} : #{name}", timetrackable_object]
    end
  end
  
  def Ticket.ticketable_for_select
    @ticketable = []
    @customers = Customer.all.each do |c|
     items = [[c.name, c.ticketable_object]] + (c.support_projects.map {|p| ["#{c.name} - #{p.name}", p.ticketable_object] })
     @ticketable.push([c.name, items.reject(&:blank?)]);
    end
    @ticketable.sort_by {|o| o[0] }
  end
  
  
  def Ticket.all_ticketable_for_select
    @ticketable = []
    @customers = Customer.all.each do |c|
     @items = [c.to_option] +
       (c.tickets.map {|t| t.to_option })
       c.support_projects.each do |p|
         @items += [p.to_option] + (p.tickets.map {|t| t.to_option })
       end
       
     @ticketable.push([c.name, @items.reject(&:blank?)])
    end
    @ticketable.sort_by {|o| o[0] }
  end
end
