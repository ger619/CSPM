class SlaBreachCheckerJob < ApplicationJob
  queue_as :sla_breach

  def perform
    # Fetch all SLA tickets where the deadline has passed
    breached_tickets = SlaTicket.where('sla_target_response_deadline < ?', Time.current)
      .where(sla_status: 'Not Breached')

    breached_tickets.each do |sla_ticket|
      sla_ticket.update(sla_status: 'Breached')

      # Notify assigned users
      sla_ticket.ticket.users.each do |user|
        UserMailer.sla_breach_email(user, sla_ticket.ticket).deliver_later
      end

      Rails.logger.info("SLA Breach detected for Ticket ##{sla_ticket.ticket.id}. Status updated.")
    end
  end
end
