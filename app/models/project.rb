class Project < ApplicationRecord
  belongs_to :user
  has_many :tickets, dependent: :destroy
  has_many :issues, foreign_key: :project_id, class_name: 'Issue', dependent: :destroy

  has_rich_text :content

  validates :title, presence: true, uniqueness: true

  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return unless end_date.present? && start_date.present? && end_date < start_date

    errors.add(:end_date, 'End Date must be greater than Start Date')
  end

  extend FriendlyId
  friendly_id :title, use: :slugged

  def name
    # Pick name name from the user_id assigned
    # to the project
    user.name
  end

  def count
    # Count the number of projects by all users
    # and display it
    Project.count
  end
end
