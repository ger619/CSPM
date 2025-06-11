# Controller for the home page/dashboard
class HomeController < ApplicationController
  # Ensure user is authenticated before accessing any action
  before_action :authenticate_user!

  # Home page action
  def index
    # If the user is a CEO, redirect to the special report page
    if user_signed_in? && current_user.has_role?(:ceo)
      redirect_to cease_fire_report_path
    else
      # Otherwise, load dashboard data

      @users = User.all.order('created_at DESC') # List all users, newest first

      # Count issues created by the current user per project
      @issues_count_per_project_for_current_user = current_user.projects
        .joins(tickets: :issues)
        .where('issues.user_id = ?', current_user.id)
        .group('projects.title')
        .count('issues.id')

      # Count all tickets per project (any user)
      @tickets_count_per_project = current_user.projects
        .joins(:tickets)
        .group('projects.title')
        .count('tickets.id')

      # Count all issues per project (any user)
      @issues_count_per_project = current_user.projects
        .joins(tickets: :issues)
        .group('projects.title')
        .count('issues.id')

      # Count tickets created by the current user per project
      @tickets_count_per_project_for_current_user = current_user.projects
        .joins(:tickets)
        .where('tickets.user_id = ?', current_user.id)
        .group('projects.title')
        .count('tickets.id')

      # Count issues created by the current user per project (duplicate, can be removed)
      @issues_count_per_project_for_current_user = current_user.projects
        .joins(tickets: :issues)
        .where('issues.user_id = ?', current_user.id)
        .group('projects.title')
        .count('issues.id')

      # Count all tickets per project (duplicate, can be removed)
      @tickets_count_per_project = current_user.projects
        .joins(:tickets)
        .group('projects.title')
        .count('tickets.id')

      # Count all issues per project (duplicate, can be removed)
      @issues_count_per_project = current_user.projects
        .joins(tickets: :issues)
        .group('projects.title')
        .count(' issues.id') # NOTE: extra space in ' issues.id' may cause issues

      # Count tickets by status across all projects
      @status_data = current_user.projects.joins(tickets: :statuses).group('statuses.name').count
      @total_tickets = @status_data.values.sum
      @status_data = { 'Total' => @total_tickets }.merge(@status_data) # Add total at the start

      # Count tickets by status per project
      @status_per_project = current_user.projects.joins(tickets: :statuses).group('projects.title', 'statuses.name').count

      # Count total tickets per project
      @total_tickets_per_project = current_user.projects
        .joins(:tickets)
        .group('projects.title')
        .count('tickets.id')

      # Calculate total tickets across all projects
      total_tickets = @total_tickets_per_project.values.sum
      @total_tickets_per_project = { 'All Projects' => total_tickets }.merge(@total_tickets_per_project)

      # Count closed and reopened tickets, and add total
      @closed_and_reopened_tickets = current_user.projects.joins(tickets: :statuses).group('statuses.name').count
      @closed_and_reopened_tickets = { 'Closed' => @closed_and_reopened_tickets['Closed'] || 0,
                                       'Reopened' => @closed_and_reopened_tickets['Reopened'] || 0 }
      @closed_and_reopened_tickets = { 'All Tickets' => total_tickets }.merge(@closed_and_reopened_tickets)

      # Prepare tickets for time-based grouping
      @tickets = current_user.projects.joins(:tickets)

      # Filter tickets by date range if provided
      if params[:start_date].present? && params[:end_date].present?
        @tickets = @tickets.where('tickets.created_at >= ? AND tickets.created_at <= ?', params[:start_date], params[:end_date])
      end

      # Determine grouping period for charts
      grouping_period = params[:grouping_period] || 'day'

      # Group tickets by day, month, or year for charting
      @chart_data = case grouping_period
                    when 'day'
                      @tickets.group_by_day('tickets.created_at', time_zone: 'UTC', format: '%Y-%m-%d').count
                    when 'month'
                      @tickets.group_by_month('tickets.created_at').count
                    when 'year'
                      @tickets.group_by_year('tickets.created_at').count
                    end

      @total_tickets_per_project.values.sum # (Unused, can be removed)

      # Prepare tickets for user-based charting
      @tickets_user = Ticket.all

      # Filter by date range if provided
      if params[:start_date].present? && params[:end_date].present?
        @tickets_user = @tickets_user.where('tickets.created_at >= ? AND tickets.created_at <= ?', params[:start_date], params[:end_date])
      end

      # Filter by user (admin can select user, others see their own)
      @tickets_user = if current_user.has_role?(:admin) && params[:user_id].present?
                        @tickets_user.joins(:users).where(users: { id: params[:user_id] })
                      else
                        @tickets_user.joins(:users).where(users: { id: current_user.id })
                      end

      @tickets_user = @tickets_user.joins(:project) # Ensure projects are joined

      grouping_period = params[:grouping_period] || 'day'

      # Group tickets per user for charting
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
      @total_tickets_per_project.values.sum # (Unused, can be removed)

      # Count SLA-breached tickets per project
      @sla_breaches_per_project = current_user.projects
        .joins(:tickets)
        .joins('INNER JOIN sla_tickets ON sla_tickets.ticket_id = tickets.id')
        .where("sla_tickets.sla_status = 'Breached'")
        .group('projects.title')
        .count

      # Count non-breached (or missing SLA) tickets per project
      @non_breached_tickets_per_project = current_user.projects
        .joins(:tickets)
        .joins('LEFT JOIN sla_tickets ON sla_tickets.ticket_id = tickets.id')
        .where("sla_tickets.sla_status = 'Not Breached' OR sla_tickets.ticket_id IS NULL")
        .group('projects.title')
        .count

      # Count ticket statuses per project
      @ticket_statuses_per_project = current_user.projects
        .joins(:tickets)
        .group('projects.title', 'tickets.status')
        .count
    end
  end
end
