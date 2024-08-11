class Project < ApplicationRecord
  belongs_to :user
  has_many :tickets, dependent: :destroy
  has_rich_text :content

  validates :title, presence: true, uniqueness: true

  extend FriendlyId
  friendly_id :title, use: :slugged

  def name
    # Pick team name from the team and display it
    "#{create_user.first_name} #{create_user.last_name}"
  end

  def count
    # Count the number of projects by all users
    # and display it
    Project.count
  end
end
