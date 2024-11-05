class Ticket < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_one_attached :ticket_image
  has_many :issues, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_rich_text :content
  has_one_attached :image

  has_paper_trail

  resourcify
  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :users
  has_many :editors, -> { where(roles: { name: :editor }) }, class_name: 'User', through: :roles, source: :users

  validate :content_length_within_limit

  has_many :taggings
  has_many :users, through: :taggings, dependent: :destroy

  has_many :add_statuses
  has_many :statuses, through: :add_statuses, dependent: :destroy

  #before_update :set_initial_response_time
  #def set_initial_response_time
  #  return unless saved_change_to_status? && status == 'assigned'

  #  update_column(:initial_response_deadline, DateTime.now)
  #end

  private

  def content_length_within_limit
    return unless content.to_plain_text.length > 800

    errors.add(:content, 'must be less than or equal to 800 characters')
  end
end
