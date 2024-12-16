class UpdateHistory < ApplicationRecord
  belongs_to :ticket
  belongs_to :user

  # Optionally, you can define a method to capture changes
  def self.record_update(ticket, user, change_details)
    create!(
      ticket: ticket,
      user: user,
      change_details: change_details,
      updated_at: Time.current
    )
  end
end
