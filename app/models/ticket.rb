class Ticket < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_one_attached :ticket_image
  has_many :issues, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_rich_text :content
  has_one_attached :image

  resourcify
  # To ensure that the ticket are connected to the user and their roles well defined
  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :users
  has_many :editors, -> { where(roles: { name: :admin }) }, class_name: 'User', through: :roles, source: :users

  validate :content_length_within_limit

  has_many :taggings
  has_many :users, through: :taggings, dependent: :destroy
  # Ticket Condition

  # after_create :set_default_status, if: :new_record?

  # Calculate the number of days left that should be calculated as per the end date
  def number_of_days_left
    return 0 unless end_date.present?

    (end_date - Date.today).to_i
  end

  private

  # To ensure that the ticket content is within the limit i.e. 800 characters

  def content_length_within_limit
    return unless content.to_plain_text.length > 800

    errors.add(:content, 'must be less than or equal to 800 characters')
  end

  # def set_sla_deadline
  #   sla_calculator = SlaCalculator.new(created_at, 24) # Assuming SLA duration is 24 hours
  #   self.sla_deadline = sla_calculator.calculate_sla_deadline
  # end
end
