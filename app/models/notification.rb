class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :ticket, optional: true

  validates :message, presence: true
  validates :read, inclusion: { in: [true, false] }

  after_create_commit :broadcast_notification

  def user_initials
    user_name = user&.name || 'NA'
    user_name.split.map(&:first).join.upcase
  end

  private

  # Broadcast the notification to the user via the NotificationsChannel
  def broadcast_notification
    NotificationsChannel.broadcast_to(user, {
                                        id: id,
                                        message: message,
                                        user_initials: user.name_initials || user.name[0..1].upcase,
                                        time_ago: ActionController::Base.helpers.time_ago_in_words(created_at),
                                        read: read
                                      })
  rescue StandardError => e
    Rails.logger.error("Failed to broadcast notification: #{e.message}")
  end
end
