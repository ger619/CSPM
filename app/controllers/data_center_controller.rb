require 'csv'
class DataCenterController < ApplicationController
    before_action :authenticate_user!
  
    def cease_fire_report
      authorize! :generate, :report # Check if the user can generate reports
  
      if params[:start_date].present? && params[:end_date].present?
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])
        @tickets = Ticket.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  
        respond_to do |format|
          format.html # Default view
          format.csv { send_data generate_csv(@tickets), filename: "cease_fire_report_#{Date.today}.csv" }
        end
      else
        @tickets = Ticket.none
        flash[:alert] = "Please provide a valid date range."
        render :cease_fire_report
      end
    end
  
    private
  
    def generate_csv(tickets)
      CSV.generate(headers: true) do |csv|
        csv << ["Summary", "Issue Key", "Issue Type", "Status", "Project Name", "Priority", "Assignee", "Reporter", "Created", "Details"]
        tickets.each do |ticket|
          csv << [
            ticket.subject,
            ticket.unique_id,
            ticket.issue,
            ticket.statuses.first&.name || "N/A",
            ticket.project.title,
            ticket.priority,
            ticket.users.map(&:name).select(&:present?).join(', '),
            ticket.user.name,
            ticket.created_at,
            ticket.content.to_plain_text.truncate(800)
          ]
        end
      end
    end
  end
  