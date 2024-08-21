class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all # allow super admins to do anything
    elsif user.has_role?('project manager')
      can :create, Project, user_id: user.id
      can :edit, Project, user_id: user.id
      can :read, Project
      can :manage, Ticket
      can :manage, Issue
    elsif user.has_role?('client' || 'agent')
      can :read, Project
      can :manage, Ticket, user_id: user.id
      can :manage, Issue, user_id: user.id
    else
      can :read, Project
      can :read, Ticket
      can :read, Issue
    end
  end
end
