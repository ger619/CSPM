class Ticket < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_one_attached :ticket_image
  has_many :issues, dependent: :destroy
  has_rich_text :body
  has_one_attached :image

  resourcify
  # To ensure that the ticket are connected to the user and their roles well defined
  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :users

  validate :content_length_within_limit

  has_many :taggings
  has_many :users, through: :taggings, dependent: :destroy
  # Ticket Condition
  enum condition: {
    open: 0,
    assigned: 1,
    awaiting_build: 2,
    client_confirmation_pending: 3,
    closed: 4,
    declined: 5,
    on_hold: 6,
    qa_testing: 7,
    reopened: 8,
    resolved: 9,
    under_development: 10,
    work_in_progress: 11
  }

  # after_create :set_default_status, if: :new_record?

  private

  # To ensure that the ticket content is within the limit i.e. 800 characters
  def content_length_within_limit
    max_length = 800 # Set your desired character limit
    return unless body.to_plain_text.length > max_length

    errors.add(:body, "cannot be longer than #{max_length} characters.")
  end
end
