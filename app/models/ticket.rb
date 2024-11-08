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

  after_create :set_initial_response_time
  def set_initial_response_time
    # return unless saved_change_to_status? && Ticket.statuses == 'assigned'

    update_column(:initial_response_deadline, next_business_time(DateTime.now, 30.minutes))
  end

  private

  def next_business_time(start_time, duration)
    business_hours = [
      { day: 1, start: 8, end: 13 }, { day: 1, start: 14, end: 17 },
      { day: 2, start: 8, end: 13 }, { day: 2, start: 14, end: 17 },
      { day: 3, start: 8, end: 13 }, { day: 3, start: 14, end: 17 },
      { day: 4, start: 8, end: 13 }, { day: 4, start: 14, end: 17 },
      { day: 5, start: 8, end: 13 }, { day: 5, start: 14, end: 17 },
      { day: 6, start: 8, end: 13 }
    ]

    end_time = start_time + duration
    end_time += 1.minute until within_business_hours?(end_time, business_hours)
    end_time
  end

  def within_business_hours?(time, business_hours)
    business_hours.any? do |hours|
      time.wday == hours[:day] && time.hour >= hours[:start] && time.hour < hours[:end]
    end
  end

  def content_length_within_limit
    return unless content.to_plain_text.length > 800

    errors.add(:content, 'must be less than or equal to 800 characters')
  end
end
