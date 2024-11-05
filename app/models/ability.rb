class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all # allow super admins to do anything
    elsif user.has_role?('project manager')
      can %i[create read unassign_user unassign_user], Project
      can %i[edit delete], Project, user_id: user.id
      can %i[create read assign_tag unassign_tag update_status add_status], Ticket
      can %i[edit destroy], Ticket, user_id: user.id
      can %i[create read], Issue
      can %i[edit delete], Issue, user_id: user.id
      can %i[create read add_user remove_user edit update], Product
      cannot %i[delete], Product
      can %i[create edit read], User, roles: { name: %w[agent client project_manager] }
      cannot :manage, User, roles: { name: 'admin' }
      can :manage, Board
      can :manage, Task
    elsif user.has_role? :client
      can :read, Project
      can %i[create read assign_tag unassign_tag update_status add_status], Ticket
      can %i[edit destroy update], Ticket, user_id: user.id

      can :manage, Issue, user_id: user.id
      cannot %i[create delete edit], Product
      can :read, Product
      cannot %i[create delete edit], Board
      cannot :manage, Task

    elsif user.has_role? :agent
      can :read, Project
      can %i[create read assign_tag unassign_tag update_status add_status], Ticket
      can %i[edit delete update], Ticket, user_id: user.id
      can :manage, Issue, user_id: user.id
      cannot %i[create delete edit], Product
      cannot %i[create delete edit], Board
      can :read, Product
      can :read, Board
      can :read, Task
    else
      can :read, Project
      can %i[create read assign_tag unassign_tag update_status add_status], Ticket
      can %i[edit delete], Ticket, user_id: user.id
      can :manage, Issue, user_id: user.id
      can :read, User, user_id: user.id
      cannot :manage, Product
      cannot :manage, Board
      cannot :manage, Task
    end
  end
end
