class Project < ApplicationRecord
  belongs_to :user
  has_many :tickets, dependent: :nullify
  has_many :issues, foreign_key: :project_id, class_name: 'Issue', dependent: :nullify

  has_rich_text :content

  resourcify
  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :admin }) }, class_name: 'User', through: :roles, source: :users
  # Assingnee
  has_many :assignees
  has_many :users, through: :assignees

  validates :title, presence: true, uniqueness: true

  validate :end_date_after_start_date

  def assigned_to?(user)
    users.include?(user)
  end

  # To have pick a list of users who have role agent only on a dropdown list at the view to assign a project

  private

  def end_date_after_start_date
    return unless end_date.present? && start_date.present? && end_date < start_date

    errors.add(:end_date, 'End Date must be greater than Start Date')
  end

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
