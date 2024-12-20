class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :ticket

  validates :message, presence: true
  validates :read, inclusion: { in: [true, false] }

  after_create_commit -> { NotificationsChannel.broadcast_to(user, self) }
end
