class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all # allow super admins to do anything
    elsif user.has_role?('project manager')
      can %i[create read unassign_user unassign_user], Project
      can %i[edit delete], Project, user_id: user.id
      can %i[create read assign_tag unassign_tag], Ticket
      can %i[edit delete], Ticket, user_id: user.id
      can %i[create read], Issue
      can %i[edit delete], Issue, user_id: user.id
      can %i[create read add_user remove_user edit], Product
      cannot %i[delete], Product
      can :manage, User, roles: { name: %w[agent client project_manager] }
      cannot :manage, User, roles: { name: 'admin' }
    elsif user.has_role? :client
      can :read, Project
      can %i[create read assign_tag unassign_tag], Ticket
      can %i[edit delete], Ticket, user_id: user.id
      can :read, Issue
      can :read, Product

    elsif user.has_role? :agent
      can :read, Project
      can %i[create read assign_tag unassign_tag], Ticket
      can %i[edit delete], Ticket, user_id: user.id
      can :manage, Issue, user_id: user.id
      can :read, Product
    else
      can :read, Project
      can %i[create read assign_tag unassign_tag], Ticket
      can %i[edit delete], Ticket, user_id: user.id
      can :read, Issue
      can :read, User, user_id: user.id
      can :read, Product
    end
  end
end
