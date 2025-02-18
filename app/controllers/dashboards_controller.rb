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
      total_tickets_last_30_days = Ticket.where(software_id: software).where('created_at >= ?', 30.days.ago).count
      breached_tickets_last_30_days = SlaTicket.joins(:ticket)
        .where(tickets: { software_id: software })
        .where('tickets.created_at >= ?', 30.days.ago)
        .where(sla_status: 'Breached')
        .count

      stats = {
        total_tickets_last_30_days: total_tickets_last_30_days,
        breached_tickets_last_30_days: breached_tickets_last_30_days
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
