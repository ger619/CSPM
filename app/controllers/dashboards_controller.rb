class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @softwares = Software.all
    @stats = get_default_stats
  end

  def fetch_stats
    software_name = params[:software_name]

    software = Software.find_by(name: software_name)&.id

    if software
      total_tickets_last_30_days = Ticket.where(software_id: software).where('created_at >= ?', 300.days.ago).count
      breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { software_id: software })
        .where('tickets.created_at >= ?', 300.days.ago)
        .where(sla_status: 'Breached')
        .count

      not_breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { software_id: software })
        .where('tickets.created_at >= ?', 300.days.ago)
        .where(sla_status: 'Not Breached')
        .count

      response_breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { software_id: software })
        .where('tickets.created_at >= ?', 300.days.ago)
        .where(sla_target_response_deadline: 'Breached')
        .count

      not_response_breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { software_id: software })
        .where('tickets.created_at >= ?', 300.days.ago)
        .where(sla_target_response_deadline: 'Not Breached')
        .count

      resolution_breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { software_id: software })
        .where('tickets.created_at >= ?', 300.days.ago)
        .where(sla_resolution_deadline: 'Breached')
        .count

      not_resolution_breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { software_id: software })
        .where('tickets.created_at >= ?', 300.days.ago)
        .where(sla_resolution_deadline: 'Not Breached')
        .count

      pending_resolution_30_days = Ticket.where(software_id: software)
        .where('created_at >= ?', 300.days.ago)
        .where(id: SlaTicket.where(sla_resolution_deadline: nil).select(:ticket_id))
        .count

      pending_initial_response_30_days = Ticket.where(software_id: software)
        .where('created_at >= ?', 300.days.ago)
        .where(id: SlaTicket.where(sla_status: nil).select(:ticket_id))
        .count

      pending_target_response_30_days = Ticket.where(software_id: software)
        .where('created_at >= ?', 300.days.ago)
        .where(id: SlaTicket.where(sla_target_response_deadline: nil).select(:ticket_id))
        .count

      breached_tickets_per_assignee = SlaTicket
        .joins(ticket: { taggings: :user }) # Ensures proper joins
        .where(tickets: { software_id: software })
        .where('tickets.created_at >= ?', 300.days.ago)
        .where(sla_target_response_deadline: 'Breached')
        .group('users.first_name', 'users.last_name')
        .count

      breached_resolution_tickets_per_project = SlaTicket
        .joins(ticket: :project) # Join the projects table
        .where(tickets: { software_id: software })
        .where('tickets.created_at >= ?', 300.days.ago)
        .where(sla_target_response_deadline: 'Breached')
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
        pending_target_response_30_days: pending_target_response_30_days
      }

      render json: stats
    else
      render json: { error: 'Software not found' }, status: :not_found
    end
  end

  private

  def get_default_stats # rubocop:disable Naming/AccessorMethodName
    # Default statistics, assuming 'BREFT' is the default software
    br_islamic_software_id = Software.find_by(name: 'BREFT')&.id
    {
      br_islamic_tickets_count: Ticket.where(software_id: br_islamic_software_id).count
    }
  end
end
