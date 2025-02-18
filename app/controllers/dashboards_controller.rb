class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @softwares = Software.all
    @stats = get_default_stats
  end

  def fetch_stats
    software_name = params[:software_name]

    # Log the software name
    Rails.logger.debug("Software Name: #{software_name}")

    software = Software.find_by(name: software_name)&.id

    if software
      tickets_count = Ticket.where(software_id: software).count
      total_tickets_last_30_days = Ticket.where(software_id: software).where('created_at >= ?', 30.days.ago).count

      # Log the counts for tickets
      Rails.logger.debug("Tickets Count: #{tickets_count}")
      Rails.logger.debug("Total Tickets in the Last 30 Days: #{total_tickets_last_30_days}")

      stats = {
        users_count: User.count,
        tickets_count: tickets_count,
        total_tickets_last_30_days: total_tickets_last_30_days
      }

      render json: stats
    else
      render json: { error: 'Software not found' }, status: :not_found
    end
  end

  private

  def get_default_stats
    # Default statistics, assuming 'BREFT' is the default software
    br_islamic_software_id = Software.find_by(name: 'BREFT')&.id
    {
      users_count: User.count,
      tickets_count: Ticket.count,
      br_islamic_tickets_count: Ticket.where(software_id: br_islamic_software_id).count
    }
  end
end
