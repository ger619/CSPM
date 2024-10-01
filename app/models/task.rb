class Task < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :board
  has_one_attached :image


  resourcify

  has_many :role_users, through: :roles, class_name: 'User', source: :user
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :user

  validate :end_date_after_start_date

  has_many :add_tasks
  has_many :users, through: :add_tasks, dependent: :destroy

  private

  def end_date_after_start_date
    return unless end_date.present? && start_date.present? && end_date < start_date

    errors.add(:end_date, 'End Date must be greater than Start Date')
  end
end
