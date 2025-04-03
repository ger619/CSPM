class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all # allow super admins to do anything
      can :generate, :report
    elsif user.has_role? :observer
      can :read, :all
      can %i[generate report cease_fire_report breach_report user_report], :report

    elsif user.has_role?('project manager')
      can %i[read assign_user unassign_user add_team], Project
      can %i[create read assign_tag unassign_tag add_status update_issue_type update_due_date update_priority index_home all_tickets], Ticket
      can %i[edit destroy update], Ticket, user_id: user.id
      can :manage, Issue, user_id: user.id
      can %i[create read add_user remove_user edit update], Product
      cannot %i[delete], Product
      can %i[create edit read], User, roles: { name: ['agent', 'client', 'project manager'] }
      cannot :manage, User, roles: { name: 'admin' }
      can :manage, Board
      can :manage, Task
      can :generate, :report
      can :manage, Team
    elsif user.has_role? :client
      can :read, Project
      can %i[create read assign_tag unassign_tag update_status add_status index_home all_tickets], Ticket
      can %i[edit destroy update], Ticket, user_id: user.id
      can :manage, Issue, user_id: user.id
      cannot %i[create delete edit], Product
      can :read, Product
      cannot %i[create delete edit], Board
      cannot :manage, Task
      can :generate, :report
    elsif user.has_role? :agent
      can %i[read assign_user unassign_user], Project
      can %i[create read assign_tag unassign_tag update_status add_status index_home all_tickets], Ticket
      can %i[edit destroy update], Ticket, user_id: user.id
      can :manage, Issue, user_id: user.id
      can :update_due_date, Ticket
      cannot %i[create delete edit], Product
      cannot %i[create delete edit], Board
      can :read, Product
      can :read, Board
      can :read, Task
      can :generate, :report
    else
      can :read, Project
      can :read, Ticket
      can :read, Issue
      can :read, User, user_id: user.id
      cannot :manage, Product
      cannot :manage, Board
      cannot :manage, Task
    end
  end
end
