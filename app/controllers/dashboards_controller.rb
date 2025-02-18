class DashboardsController < ApplicationController
  before_action :authenticate_user!
  def index
    @stats = {
      users_count: User.count,
      tickets_count: Ticket.count
    }
  end
end
