require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  def setup
    @customer = Customer.new :name => 'Test customer',
                             :user_id => users(:user1).id
  end

  def test_should_save_customer
    assert @customer.save, 'saved a valid customer'
  end

  def test_should_not_save_customer_without_name
    @customer.name = nil
    assert !@customer.save, 'saved a customer without a name'
  end

  def test_should_not_save_customer_without_user
    @customer.user = nil
    assert !@customer.save, 'saved a customer without a user'
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

  def test_returns_users
    assert_kind_of Array, customers(:customer1).users
    assert_equal 1, customers(:customer1).users.count
    Stakeholder.create :user => users(:user2),
      :project => projects(:project1), :role => 'developer'
    assert_equal 2, customers(:customer1).users(true).count
  end

  def test_has_stakeholder
    assert customers(:customer1).has_stakeholder?(users(:user1))
    assert !customers(:customer1).has_stakeholder?(users(:user2))
  end
end
