class Issue < ApplicationRecord
  belongs_to :ticket
  belongs_to :project
  belongs_to :user

  has_rich_text :content
  has_many_attached :attachments

  resourcify

  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :users

  validate :content_length_within_limit

  private

  def content_length_within_limit
    return unless content.to_plain_text.length > 3000

    errors.add(:content, 'must be less than or equal to 800 characters')
  end
end
