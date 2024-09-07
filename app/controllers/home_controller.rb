class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @users = User.all.order('created_at DESC')
    # Count the number of issues created by the current user per project
    @issues_count_per_project_for_current_user = current_user.projects # Get all projects the current user is a member
      .joins(tickets: :issues) # Join the projects, tickets, and issues tables
      .where('issues.user_id = ?', current_user.id) # Only count issues by the current user
      .group('projects.title') # Group the results by project title
      .count('issues.id') # Count the total number of issues created by the current user for each project

    # Count the total number of tickets created for each project (by anyone)
    @tickets_count_per_project = current_user.projects # Get all projects the current user is a member of
      .joins(:tickets) # Join the projects and tickets tables
      .group('projects.title') # Group the results by project title
      .count('tickets.id') # Count the total number of tickets created for each project

    # Count the total number of issues created for each project (by anyone)
    @issues_count_per_project = current_user.projects # Get all projects the current user is a member of
      .joins(tickets: :issues) # Join the projects, tickets, and issues tables
      .group('projects.title') # Group the results by project title
      .count('issues.id') # Count the total number of issues created for each project

    # Count the total number of tickets created by the current user for each project
    @tickets_count_per_project_for_current_user = current_user.projects # Get all projects the current user is a member
      .joins(:tickets) # Join the projects and tickets tables
      .where('tickets.user_id = ?', current_user.id) # Only count tickets by the current user
      .group('projects.title') # Group the results by project title
      .count('tickets.id') # Count the total number of tickets created by the current user for each project

    # Count the total number of tickets created by the current user for each project
    @issues_count_per_project_for_current_user = current_user.projects # Get all projects the current user is a member
      .joins(tickets: :issues) # Join the projects, tickets, and issues tables
      .where('issues.user_id = ?', current_user.id) # Only count issues by the current user
      .group('projects.title') # Group the results by project title
      .count('issues.id') # Count the total number of issues created by the current user for each project

    # Count the total number of tickets created for each project (by anyone)
    @tickets_count_per_project = current_user.projects # Get all projects the current user is a member of
      .joins(:tickets) # Join the projects and tickets tables
      .group('projects.title') # Group the results by project title
      .count('tickets.id') # Count the total number of tickets created for each project

    # Count the total number of issues created for each project (by anyone)
    @issues_count_per_project = current_user.projects # Get all projects the current user is a member of
      .joins(tickets: :issues) # Join the projects, tickets, and issues tables
      .group('projects.title') # Group the results by project title
      .count(' issues.id') # Count the total number of issues created for each project
  end
end
