require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  def setup
    @customer = Factory.create(:customer)
  end

  def test_should_save_customer
    assert @customer.save, 'saved a valid customer'
  end

  def test_should_not_save_customer_without_name
    @customer.name = nil
    assert !@customer.save, 'saved a customer without a name'
  end

  def test_customer_name_should_be_unique
    assert @customer.save
    assert !@customer.clone.save, 'saved a customer with a duplicate name'
  end

  def test_delete_should_delete_projects
    assert_difference 'Project.all.length',-1 do
      customers(:customer1).destroy
    end
  end
end
