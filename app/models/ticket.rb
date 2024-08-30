class Ticket < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_one_attached :ticket_image
  has_many :issues, dependent: :nullify
  has_rich_text :body
  has_one_attached :image

  resourcify
  # To ensure that the ticket are connected to the user and their roles well defined
  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :users

  validate :content_length_within_limit

  has_many :taggings
  has_many :users, through: :taggings

  # Check if user has been assigned into the project
  # before tagging the ticket
  # If not assigned, the user cannot tag the ticket
  # If assigned, the user can tag the ticket
  def tagging_to?(user)
    users << user if project.users.include?(user)
  end

  private

  # To ensure that the ticket content is within the limit i.e. 800 characters
  def content_length_within_limit
    max_length = 800 # Set your desired character limit
    return unless body.to_plain_text.length > max_length

    errors.add(:body, "cannot be longer than #{max_length} characters.")
  end
end
