require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = Project.new :name => 'Test project',
                           :customer_id => customers(:customer1).id,
                           :estimate => 100
  end

  def test_should_save_project
    assert @project.save, 'saved a valid customer'
  end

  def test_should_not_save_project_without_name
    @project.name = nil
    assert !@project.save, 'saved a project without a name'
  end

  def test_should_not_save_project_without_customer
    @project.customer = nil
    assert !@project.save, 'saved a project without a name'
  end

  def test_should_delete_dependent_tasks
    assert_difference 'Task.count', -1 do
      projects(:project1).destroy
    end
  end

  def test_should_delete_dependent_stakeholders
    assert_difference 'Stakeholder.count', -1 do
      projects(:project1).destroy
    end
  end

  def test_should_return_if_user_is_stakeholder
    assert projects(:project1).has_stakeholder?(users(:user1)),
      "project has stakeholder"
    assert !projects(:project1).has_stakeholder?(users(:user2)),
      "project doesn't have stakeholder"
  end

  def test_should_add_stakeholder
    assert_difference 'Stakeholder.count' do
      assert_instance_of Stakeholder,
        projects(:project2).add_stakeholder(users(:user1))
    end
  end

  def test_should_save_without_estimate
    @project.estimate = nil
    assert @project.save, 'saved project without estimate'
  end

  def test_should_not_save_with_invalid_estimate
    @project.estimate = 'cheesemeister'
    assert !@project.save, 'saved project with a string estimate'
    @project.estimate = 0
    assert !@project.save, 'saved project with invalid 0 estimate'
    @project.estimate = -56
    assert !@project.save, 'saved project with invalid negative estimate'
    @project.estimate = 10.2
    assert @project.save, 'saved project with invalid decimal estimate'
  end
end
