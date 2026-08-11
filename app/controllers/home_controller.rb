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
      # Count tickets by status per project
      # Count total tickets per project

      # Prepare tickets for time-based grouping
      @tickets = current_user.projects.joins(:tickets)

      # Filter tickets by date range if provided
      if params[:start_date].present? && params[:end_date].present?
        @tickets = @tickets.where('tickets.created_at >= ? AND tickets.created_at <= ?', params[:start_date], params[:end_date])
      end

      # Determine grouping period for charts

      # Group tickets by day, month, or year for charting

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

      # Count ticket statuses per project
      @ticket_statuses_per_project = current_user.projects
        .joins(:tickets)
        .group('projects.title', 'tickets.status')
        .count

      # Count of the tickets closed in the last one week
      @tickets_closed_in_last_one_week_count = Ticket.joins(:statuses)
        .where(statuses: { name: %w[Closed Resolved Declined] })
        .where('tickets.updated_at >= ?', 1.week.ago)
        .count

      # All the open tickets for the current user count
      @all_open_tickets_for_current_user_count = Ticket.joins(:statuses)
        .where.not(statuses: { name: %w[Closed Resolved Declined] })
        .distinct
        .count

      # COunt of all tickets created in the last one week count
      @tickets_created_in_last_one_week_count = Ticket.where('created_at >= ?', 1.week.ago).count

      # Get the total number of open tickets for the current user count
      @total_no_of_open_tickets_for_current_user_count = Ticket.joins(:statuses, :project)
        .where(projects: { id: current_user.projects.ids })
        .where.not(statuses: { name: %w[Closed Resolved Declined] })
        .distinct
        .count

      # Count of all the tickets
      @all_tickets_count = Ticket.distinct.count

      # Users who have logged in more than once count
      @users_who_have_loggedin_more_than_once_count = User.joins(:roles)
        .where(roles: { name: ['client', 'project manager', 'admin', 'agent', 'observer'] })
        .where('sign_in_count > ?', 0)
        .count

      # Clients who have logged in more than once count
      @clients_who_have_loggedin_more_than_once_count = User.joins(:roles)
        .where(roles: { name: 'client' })
        .where('sign_in_count > ?', 0)
        .count

      # Project managers who have logged in more than once count
      @project_managers_who_have_loggedin_more_than_once_count = User.joins(:roles)
        .where(roles: { name: 'project manager' })
        .where('sign_in_count > ?', 0)
        .count

      # Agents who have logged in more than once count
      @agents_who_have_loggedin_more_than_once_count = User.joins(:roles)
        .where(roles: { name: 'agent' })
        .where('sign_in_count > ?', 0)
        .count

      # Count the total number of service desks\
      @all_service_desks_count = Project.distinct.count
    end
  end
end
