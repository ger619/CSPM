class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @teams = Team.all
    @stats = default_stats
  end

  def fetch_stats
    team_name = params[:team_name]

    team = Team.find_by(name: team_name)&.id

    if team
      user_ids = Team.find(team).users.pluck(:id)
      total_tickets_last_30_days = Ticket.where(user_id: user_ids).where('created_at >= ?', 30.days.ago).count
      breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { user_id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .where(sla_status: 'Breached')
        .count

      not_breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { user_id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .where(sla_status: 'Not Breached')
        .count

      response_breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { user_id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .where(sla_target_response_deadline: 'Breached')
        .count

      not_response_breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { user_id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .where(sla_target_response_deadline: 'Not Breached')
        .count

      resolution_breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { user_id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .where(sla_resolution_deadline: 'Breached')
        .count

      not_resolution_breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { user_id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .where(sla_resolution_deadline: 'Not Breached')
        .count

      pending_resolution_30_days = Ticket.where(user_id: user_ids)
        .where('created_at >= ?', 30.days.ago)
        .where(id: SlaTicket.where(sla_resolution_deadline: nil).select(:ticket_id))
        .count

      pending_initial_response_30_days = Ticket.where(user_id: user_ids)
        .where('created_at >= ?', 30.days.ago)
        .where(id: SlaTicket.where(sla_status: nil).select(:ticket_id))
        .count

      pending_target_response_30_days = Ticket.where(user_id: user_ids)
        .where('created_at >= ?', 30.days.ago)
        .where(id: SlaTicket.where(sla_target_response_deadline: nil).select(:ticket_id))
        .count

      breached_tickets_per_assignee = SlaTicket
        .joins(ticket: { taggings: :user }) # Ensures proper joins
        .where(tickets: { user_id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .where(sla_target_response_deadline: 'Breached')
        .group('users.first_name', 'users.last_name')
        .count

      breached_resolution_tickets_per_project = SlaTicket
        .joins(ticket: :project) # Join the projects table
        .where(tickets: { user_id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .where(sla_target_response_deadline: 'Breached')
        .group('projects.title') # Group by project title
        .count

      breached_tickets_resolved_per_assignee = SlaTicket
        .joins(ticket: { taggings: :user }) # Ensures proper joins
        .where(tickets: { user_id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .where(sla_resolution_deadline: 'Breached')
        .group('users.first_name', 'users.last_name')
        .count

      breached_resolution_resolved_tickets_per_project = SlaTicket
        .joins(ticket: :project) # Join the projects table
        .where(tickets: { user_id: user_ids })
        .where('tickets.created_at >= ?', 30.days.ago)
        .where(sla_resolution_deadline: 'Breached')
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
        pending_resolution_30_days: pending_resolution_30_days,
        pending_initial_response_30_days: pending_initial_response_30_days,
        breached_tickets_resolved_per_assignee: breached_tickets_resolved_per_assignee,
        breached_resolution_resolved_tickets_per_project: breached_resolution_resolved_tickets_per_project,
        pending_target_response_30_days: pending_target_response_30_days
      }

      render json: stats
    else
      render json: { error: 'Team not found' }, status: :not_found
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
