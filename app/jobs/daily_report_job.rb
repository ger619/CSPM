class DailyReportJob < ApplicationJob
  queue_as :default

  def perform
    Team.find_each do |team|
      send_report_to_team(team)
    end
  end

  private

  def send_report_to_team(team)
    outstanding_statuses = %w[Closed Resolved Declined]

    user_ids = team.users.pluck(:id)

    base_scope = Ticket.joins(:users, project: :client)
      .joins(:statuses, :add_statuses, :taggings)
      .where(users: { id: user_ids })

    tickets = base_scope.where.not(statuses: { name: outstanding_statuses })
      .order('add_statuses.updated_at DESC')

    hod_emails = team.users.select { |u| u.has_role?(:hod) }.map(&:email)
    mail_options = {}
    mail_options[:cc] = hod_emails if hod_emails.any?

    team.users.each do |user|
      tagged_tickets = tickets.select('tickets.*, add_statuses.updated_at')
        .joins(:taggings)
        .where(taggings: { user_id: user.id })
        .order('add_statuses.updated_at DESC')
        .distinct

      UserMailer.daily_ticket_email(user, tagged_tickets.to_a, mail_options).deliver_later if tagged_tickets.any?
    end
  end
end
