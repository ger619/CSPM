class Product < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :softwares
  has_and_belongs_to_many :groupwares
  has_and_belongs_to_many :scripts
  belongs_to :client
  has_many :bugs
  has_many :boards, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :documents, dependent: :destroy
  accepts_nested_attributes_for :documents, allow_destroy: true
  has_one_attached :image

  has_rich_text :content

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }

  resourcify
  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :admin }) }, class_name: 'User', through: :roles, source: :users

  has_many :addusers
  has_many :users, through: :addusers, dependent: :destroy

  validate :end_date_after_start_date

  def added_to?(user)
    users.include?(user)
  end

  private

  def content_length_within_limit
    return unless content.to_plain_text.length > 800

    errors.add(:content, 'must be less than or equal to 800 characters')
  end

  def end_date_after_start_date
    return unless end_date.present? && start_date.present? && end_date < start_date

    errors.add(:end_date, 'End Date must be greater than Start Date')
  end

  def count
    # Count the number of projects by all users
    # and display it
    Product.count
  end
end
