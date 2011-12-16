require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = Project.new :name => 'Test project',
                           :customer_id => customers(:customer1).id,
                           :estimate => 100
  end

  test "should save project" do
    assert @project.save, 'saved a valid customer'
  end

  test "should not save project without name" do
    @project.name = nil
    assert !@project.save, 'saved a project without a name'
  end

  test "should not save project without customer" do
    @project.customer = nil
    assert !@project.save, 'saved a project without a name'
  end

  test "should delete dependent tasks" do
    assert_difference 'Task.count', -1 do
      projects(:project1).destroy
    end
  end

  test "should delete dependent stakeholders" do
    assert_difference 'Stakeholder.count', -1 do
      projects(:project1).destroy
    end
  end

  test "should return if user is stakeholder" do
    assert projects(:project1).has_stakeholder?(users(:user1)),
      "project has stakeholder"
    assert !projects(:project1).has_stakeholder?(users(:user2)),
      "project doesn't have stakeholder"
  end

  test "should add stakeholder" do
    assert_difference 'Stakeholder.count' do
      assert_instance_of Stakeholder,
        projects(:project2).add_stakeholder(users(:user1))
    end
  end

  test "should save without estimate" do
    @project.estimate = nil
    assert @project.save, 'saved project without estimate'
  end

  test "should not save with invalid estimate" do
    @project.estimate = 'cheesemeister'
    assert !@project.save, 'saved project with a string estimate'
    @project.estimate = 0
    assert !@project.save, 'saved project with invalid 0 estimate'
    @project.estimate = -56
    assert !@project.save, 'saved project with invalid negative estimate'
    @project.estimate = 10.2
    assert @project.save, 'saved project with invalid decimal estimate'
  end

  test "should return total chargeable hours" do
    assert_equal 0.00, @project.total_chargeable_hours
    assert_equal 3.00, projects(:project1).total_chargeable_hours
  end

  test "should return percentage of budget used" do
    assert_equal 0, @project.percentage_of_budget_used

    @project.estimate = nil
    assert_nil @project.percentage_of_budget_used

    assert_equal 15, projects(:project1).percentage_of_budget_used
  end

  test "should return percentage complete" do
    assert_equal 0, @project.percentage_complete
    assert_equal 0, projects(:project1).percentage_complete
    assert tasks(:task2).update_attribute(:state, 'accepted')
    assert_equal 100, projects(:project2).percentage_complete
  end

  test "should test if project is overrunning budget" do
    assert !projects(:project1).overrunning?
    projects(:project1).estimate = 6
    assert projects(:project1).overrunning?
  end
end
