class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all # allow super admins to do anything
    elsif user.has_role?('project manager')
      can :create, Project
      can :edit, Project, user_id: user.id
      can :read, Project
      can :delete, Project, user_id: user.id
      can :create, Ticket
      can :edit, Ticket, user_id: user.id
      can :read, Ticket
      can :delete, Ticket, user_id: user.id
      can :create, Issue
      can :edit, Issue, user_id: user.id
      can :read, Issue
      can :delete, Issue, user_id: user.id
    elsif user.has_role? :client
      can :read, Project
      can :manage, Ticket, user_id: user.id
      can :create, Issue, user_id: user.id
      can :edit, Issue, user_id: user.id
      can :delete, Issue, user_id: user.id
      can :read, Issue
    elsif user.has_role? :agent
      can :read, Project
      can :manage, Ticket, user_id: user.id
      can :create, Issue, user_id: user.id
      can :edit, Issue, user_id: user.id
      can :delete, Issue, user_id: user.id
    else
      can :read, Project
      can :read, Ticket
      can :read, Issue
    end
  end
end
