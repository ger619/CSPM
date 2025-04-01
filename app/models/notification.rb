class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :ticket
  after_create_commit -> { broadcast_notification }

  # Broadcasts the notification to the user
  def broadcast_notification
    NotificationsChannel.broadcast_to(user, self)
  end

  validates :message, presence: true
  validates :read, inclusion: { in: [true, false] }
end
