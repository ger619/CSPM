class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @users = User.all.order('created_at DESC')
    @project_ticket_counts = current_user.projects.joins(:tickets).group('projects.title').count('tickets.id')
  end
end
