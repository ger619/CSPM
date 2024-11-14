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

    # @status_data = current_user.projects.joins(tickets: :statuses).group('statuses.name').count

    @status_data = current_user.projects.joins(tickets: :statuses).group('statuses.name').count
    @total_tickets = @status_data.values.sum
    # @status_data['Total'] = @total_tickets # to make it appear at the far right
    @status_data = { 'Total' => @total_tickets }.merge(@status_data)

    @status_per_project = current_user.projects.joins(tickets: :statuses).group('projects.title', 'statuses.name').count

    # Total tickets per project
    @total_tickets_per_project = current_user.projects
      .joins(:tickets)
      .group('projects.title')
      .count('tickets.id')

    # Calculate the total number of tickets for all projects
    total_tickets = @total_tickets_per_project.values.sum

    # Create a new hash with "All Projects" as the first entry
    @total_tickets_per_project = { 'All Projects' => total_tickets }.merge(@total_tickets_per_project)

    # Filter and group tickets by "closed" and "reopened" statuses
    @closed_and_reopened_tickets = current_user.projects.joins(tickets: :statuses).group('statuses.name').count
    @closed_and_reopened_tickets = { 'Closed' => @closed_and_reopened_tickets['Closed'] || 0,
                                     'Reopened' => @closed_and_reopened_tickets['Reopened'] || 0 }
    # Total ticket counts
    @closed_and_reopened_tickets = { 'All Tickets' => total_tickets }.merge(@closed_and_reopened_tickets)
  end
end
