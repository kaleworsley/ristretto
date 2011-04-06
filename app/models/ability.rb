class Ability
  include CanCan::Ability

  def initialize(user, request)

    user ||= User.new

    # A user can manage their own profile
    can :manage, User, :id => user.id

    # All users can access the ical feed
    can :ical, Project

    can :ical, Timeslice

    if user.is_staff?
      # Staff can do anything
      can :manage, :all
    else
      # TODO Needs refinement, perhaps only show users who are
      # related stakeholders?
      can :show, User do |u|
        u && user.users.detect {|a| a == u}
      end


      # Comments

      # Non-staff can read comments if they're a stakeholder in the project the
      # comment is associated with
      can :read, Comment do |comment|
        comment && comment.has_stakeholder?(user)
      end

      # Non-staff can create comments if they're a stakeholder in the project the
      # comment is associated with
      can :create, Comment do |comment|
        comment && comment.has_stakeholder?(user)
      end

      # Non-staff can update or destroy comments if they're a stakeholder in the
      # project the comment is associated with and is the creator of the comment
      can [:update, :destroy, :delete], Comment do |comment|
        comment && comment.has_stakeholder?(user) && comment.user_id == user.id
      end

      # Tasks

      # Non-staff can read tasks if they're a stakeholder in the project the
      # task is associated with
      can [:read, :enable_mail, :disable_mail], Task do |task|
        task && task.has_stakeholder?(user)
      end

      # Non-staff can create tasks if they're a stakeholder in the project the
      # task is associated with
      can :create, Task do |task|
        task && task.has_stakeholder?(user)
      end

      # Non-staff can update or destroy tasks if they're a stakeholder in the
      # project the task is associated with and is the creator of the task
      can [:update, :destroy, :delete], Task do |task|
        # FIXME: This needs a re-think
        task && task.has_stakeholder?(user) && (task.user_id == user.id || (request.params["task"] && request.params["task"].keys.eql?(['state'])))
      end

      # Attachments

      # Non-staff can download and read attachments if they're a stakeholder in the project the
      # attachment is associated with
      can [:download, :read], Attachment do |attachment|
        attachment && attachment.attachable.has_stakeholder?(user)
      end

      # Non-staff can create attachments if they're a stakeholder in the project the
      # attachment is associated with
      can :create, Attachment do |attachment|
        attachment && attachment.has_stakeholder?(user)
      end

      # Non-staff can update or destroy attachments if they're a stakeholder in the
      # project the attachment is associated with and is the creator of the attachment
      can [:update, :destroy, :delete], Attachment do |attachment|
        attachment && attachment.has_stakeholder?(user) && attachment.user_id == user.id
      end

      # Timeslices

      # Non-staff can read timeslices if they're a stakeholder in the project the
      # timeslice is associated with
      can :read, Timeslice do |timeslice|
        timeslice && timeslice.has_stakeholder?(user)
      end

      # Non-staff can access the sales order tracker
      can :invoice_tracker, Timeslice do |timeslice|
        true
      end

      # Projects

      # Non-staff can read and watch projects if they're a stakeholder
      can [:read, :watch, :enable_mail, :disable_mail], Project do |project|
        project && project.has_stakeholder?(user)
      end

      # Non-staff can index projects
      can :index, Project

      # Customers

      # Non-staff can view custormers if the're a stakeholder in one of the customer's
      # projects
      can :show, Customer do |customer|
        customer && customer.has_stakeholder?(user)
      end
    end
  end
end
