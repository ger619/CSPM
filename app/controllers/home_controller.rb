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

    # Count the number of tickets created per day
    @tickets = current_user.projects.joins(:tickets)

    if params[:start_date].present? && params[:end_date].present?
      @tickets = @tickets.where('created_at >= ? AND created_at <= ?', params[:start_date], params[:end_date])
    end

    grouping_period = params[:grouping_period] || 'day'

    @chart_data = case grouping_period
                  when 'day'
                    @tickets.group_by_day(:created_at, time_zone: 'UTC', format: '%Y-%m-%d').count
                  when 'month'
                    @tickets.group_by_month(:created_at).count
                  when 'year'
                    @tickets.group_by_year(:created_at).count
                  end

    @total_tickets_per_project.values.sum

    # Add a column graph with a search and filter feature that include users
    # @chart_data_display

    @tickets_user = Ticket.all

    if params[:start_date].present? && params[:end_date].present?
      @tickets_user = @tickets_user.where('tickets.created_at >= ? AND tickets.created_at <= ?', params[:start_date], params[:end_date])
    end

    @tickets_user = if current_user.has_role?(:admin) && params[:user_id].present?
                      @tickets_user.joins(:users).where(users: { id: params[:user_id] })
                    else
                      @tickets_user.joins(:users).where(users: { id: current_user.id })
                    end

    @tickets_user = @tickets_user.joins(:project) # Ensure projects table is joined

    grouping_period = params[:grouping_period] || 'day'

    @chart_data_per_user = case grouping_period
                           when 'day'
                             @tickets_user.group("CONCAT(users.first_name, ' ', users.last_name)").group_by_day(
                               'tickets.created_at', time_zone: 'UTC', format: '%Y-%m-%d'
                             ).count
                           when 'month'
                             @tickets_user.group("CONCAT(users.first_name, ' ', users.last_name)").group_by_month('tickets.created_at').count
                           when 'year'
                             @tickets_user.group("CONCAT(users.first_name, ' ', users.last_name)").group_by_year('tickets.created_at').count
                           end

    @total_tickets_per_project = @tickets_user.group('projects.title').count('tickets.id')
    @total_tickets_per_project.values.sum

    # Visualise SLA breaches and ticket statuses through graphs per project

    # Visualise SLA breaches and ticket statuses through graphs per project
    @sla_breaches_per_project = current_user.projects
      .joins(:tickets)
      .joins('INNER JOIN sla_tickets ON sla_tickets.ticket_id = tickets.id')
      .where("sla_tickets.sla_status = 'Breached'") # Assuming you have a way to define SLA breach
      .group('projects.title')
      .count

    @non_breached_tickets_per_project = current_user.projects
      .joins(:tickets)
      .joins('LEFT JOIN sla_tickets ON sla_tickets.ticket_id = tickets.id')
      .where("sla_tickets.sla_status = 'Not Breached' OR sla_tickets.ticket_id IS NULL") # Assuming you have a way to define SLA breach
      .group('projects.title')
      .count

    @ticket_statuses_per_project = current_user.projects
      .joins(:tickets)
      .group('projects.title', 'tickets.status')
      .count

    @clients = Client.all
    @projects = Project.all

    @tickets = if params[:client_ids].present? && params[:project_ids].present?
                 Ticket.joins(:project).where(projects: { client_id: params[:client_ids], id: params[:project_ids] })
               else
                 Ticket.none
               end

    @tickets_by_project_status = @tickets.group('projects.title', 'tickets.status').count

    # Prepare data for the chart
    @chart_data_two = @tickets_by_project_status.map do |(project, status), count|
      { name: "#{project} - #{status}", data: { status => count } }
    end
  end
end
