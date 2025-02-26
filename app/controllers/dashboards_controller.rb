class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @teams = Team.all
    @stats = default_stats
    @selected_team = params[:team_name]
  end

  def fetch_stats
    team_name = params[:team_name]

    team = Team.find_by(name: team_name)&.id

    if team
      user_ids = Team.find(team).users.pluck(:id)
      total_tickets_last_30_days = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .count
      # Breached tickets per Team
      breached_tickets_last_30_days = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .joins(:sla_tickets)
        .where(sla_tickets: { sla_status: 'Breached' })
        .count
      # Not Breached tickets per Team
      not_breached_tickets_last_30_days = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .joins(:sla_tickets)
        .where(sla_tickets: { sla_status: ['Not Breached', nil] })
        .count
      # Breached response deadline tickets per Team
      response_breached_tickets_last_30_days = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .joins(:sla_tickets)
        .where(sla_tickets: { sla_target_response_deadline: 'Breached' })
        .count
      # Not Breached response deadline tickets per Team
      not_response_breached_tickets_last_30_days = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .joins(:sla_tickets)
        .where(sla_tickets: { sla_target_response_deadline: ['Not Breached', nil] })
        .count
      # Breached resolution deadline tickets per Team
      resolution_breached_tickets_last_30_days = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .joins(:sla_tickets)
        .where(sla_tickets: { sla_resolution_deadline: 'Breached' })
        .count
      # Not Breached resolution deadline tickets per Team
      not_resolution_breached_tickets_last_30_days = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .joins(:sla_tickets)
        .where(sla_tickets: { sla_resolution_deadline: ['Not Breached', nil] })
        .count

      # Breached tickets per assignee to select per team working
      breached_tickets_per_assignee = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .joins(:sla_tickets)
        .where(sla_tickets: { sla_target_response_deadline: 'Breached' })
        .group('users.first_name', 'users.last_name')
        .count

      breached_resolution_tickets_per_project = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .joins(:sla_tickets)
        .where(sla_tickets: { sla_target_response_deadline: 'Breached' })
        .joins(:project) # Join the projects table
        .group('projects.title') # Group by project title
        .count

      # Breached tickets resolved per assignee (Working)
      breached_tickets_resolved_per_assignee = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .joins(:sla_tickets)
        .where(sla_tickets: { sla_resolution_deadline: 'Breached' })
        .group('users.first_name', 'users.last_name')
        .count

      breached_resolution_resolved_tickets_per_project = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .joins(:sla_tickets)
        .where(sla_tickets: { sla_resolution_deadline: 'Breached' })
        .joins(:project) # Join the projects table
        .group('projects.title') # Group by project title
        .count

      stats = {
        total_tickets_last_30_days: total_tickets_last_30_days,
        breached_tickets_last_30_days: breached_tickets_last_30_days,
        not_breached_tickets_last_30_days: not_breached_tickets_last_30_days,
        response_breached_tickets_last_30_days: response_breached_tickets_last_30_days,
        not_response_breached_tickets_last_30_days: not_response_breached_tickets_last_30_days,
        resolution_breached_tickets_last_30_days: resolution_breached_tickets_last_30_days,
        not_resolution_breached_tickets_last_30_days: not_resolution_breached_tickets_last_30_days,
        breached_tickets_per_assignee: breached_tickets_per_assignee,
        breached_resolution_tickets_per_project: breached_resolution_tickets_per_project,
        breached_tickets_resolved_per_assignee: breached_tickets_resolved_per_assignee,
        breached_resolution_resolved_tickets_per_project: breached_resolution_resolved_tickets_per_project
      }

      render json: stats
    else
      render json: { error: 'Team not found' }, status: :not_found
    end
  end

  def tickets
    team_name = params[:team_name]
    type = params[:type]
    team = Team.find_by(name: team_name)&.id

    if team
      user_ids = Team.find(team).users.pluck(:id)
      @tickets = Ticket.joins(:users)
        .where(users: { id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .joins(:sla_tickets)

      case type
      when 'initial_response_time_breached'
        @tickets = @tickets.where(sla_tickets: { sla_target_response_deadline: 'Breached' })
      when 'initial_response_time_not_breached'
        @tickets = @tickets.where(sla_tickets: { sla_target_response_deadline: ['Not Breached', nil] })
      when 'target_repair_time_breached'
        @tickets = @tickets.where(sla_tickets: { sla_target_response_deadline: 'Breached' })
      when 'target_repair_time_not_breached'
        @tickets = @tickets.where(sla_tickets: { sla_target_response_deadline: ['Not Breached', nil] })
      when 'target_resolution_time_breached'
        @tickets = @tickets.where(sla_tickets: { sla_resolution_deadline: 'Breached' })
      when 'target_resolution_time_not_breached'
        @tickets = @tickets.where(sla_tickets: { sla_resolution_deadline: ['Not Breached', nil] })
      when 'total_tickets_last_30_days'
        # No additional filtering needed
      else
        @tickets = []
      end
    else
      @tickets = []
    end
  end

  private

  def default_stats
    # Default statistics, assuming 'Default Team' is the default team
    default_team = Team.find_by(name: 'Default Team')

    if default_team
      user_ids = default_team.users.pluck(:id)
      {
        total_tickets_last_30_days: Ticket.where(user_id: user_ids).where('created_at >= ?', 30.days.ago).count
      }
    else
      {
        total_tickets_last_30_days: 0
      }
    end
  end
end
