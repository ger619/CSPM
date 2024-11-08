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
    start_time = DateTime.now
    start_time = adjust_start_time(start_time)
    update_column(:initial_response_deadline, next_business_time(start_time, 30.minutes))
  end

  def sla_status
    # For Sla to be met, the ticket must change status to from status.nil? to status.present within the first 30 minutes
    # Show the ticket status is not blank
    return unless statuses.exists?

    update_column(:status, 'true')
  end

  private

  def adjust_start_time(start_time)
    business_hours = [
      { day: 1, start: 8, end: 13 }, { day: 1, start: 14, end: 17 },
      { day: 2, start: 8, end: 13 }, { day: 2, start: 14, end: 17 },
      { day: 3, start: 8, end: 13 }, { day: 3, start: 14, end: 17 },
      { day: 4, start: 8, end: 13 }, { day: 4, start: 14, end: 17 },
      { day: 5, start: 8, end: 13 }, { day: 5, start: 14, end: 17 },
      { day: 6, start: 8, end: 13 }
    ]

    until within_business_hours?(start_time, business_hours)
      start_time += 1.minute
      # Skip time between 1pm and 2pm
      if start_time.hour == 13
        start_time = start_time.change(hour: 14, min: 0)
      end
      # Skip time after 5pm
      if start_time.hour >= 17
        start_time = start_time.change(hour: 8, min: 0) + 1.day
      end
      # Skip non-business days (Sunday)
      if start_time.wday == 0
        start_time = start_time.change(hour: 8, min: 0) + 1.day
      end
    end
    start_time
  end

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
    until within_business_hours?(end_time, business_hours)
      end_time += 1.minute
      # Skip time between 1pm and 2pm
      if end_time.hour == 13
        end_time = end_time.change(hour: 14, min: 0)
      end
      # Skip time after 5pm
      if end_time.hour >= 17
        end_time = end_time.change(hour: 8, min: 0) + 1.day
      end
      # Skip non-business days (Sunday)
      if end_time.wday == 0
        end_time = end_time.change(hour: 8, min: 0) + 1.day
      end
    end
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
