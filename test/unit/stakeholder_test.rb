require 'test_helper'

class StakeholderTest < ActiveSupport::TestCase

  def test_roles_for_select
    roles = [
              ['Project manager', 'project_manager'],
              ['Customer representative', 'customer_representative'],
              ['Developer', 'developer'],
              ['Designer', 'designer'],
              ['Support', 'support'],
              ['Accounts', 'accounts'],
              ['Scrum master', 'scrum_master']
            ]
    assert_equal roles, Stakeholder.roles_for_select
  end
end
