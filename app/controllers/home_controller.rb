class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @users = User.all.order('created_at DESC')

    # Count the number of issues created by the current user per project
    @issues_count_per_project_for_current_user = current_user.projects
      .joins(tickets: :issues)
      .where('issues.user_id = ?', current_user.id) # Only count issues by the current user
      .group('projects.title')
      .count('issues.id')

    # Count the total number of tickets created for each project (by anyone)
    @tickets_count_per_project = current_user.projects
      .joins(:tickets)
      .group('projects.title')
      .count('tickets.id')
  end
end
