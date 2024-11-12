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
  after_create :create_sla_status

  def set_initial_response_time
    start_time = DateTime.now
    start_time = adjust_start_time(start_time)
    update_column(:initial_response_deadline, next_business_time(start_time, 30.minutes))
  end

  def sla_status
    return 'Still Pending' if pending?
    return 'Still Pending to Assign' if pending_to_assign?
    return 'on time' if on_time?

    'Breached' if breached?
  end

  private

  def pending?
    users.none? && initial_response_deadline < DateTime.now
  end

  def pending_to_assign?
    users.none? && initial_response_deadline > DateTime.now
  end

  def on_time?
    users.any? && initial_response_deadline >= DateTime.now
  end

  def breached?
    users.any? && initial_response_deadline < DateTime.now
  end

  def create_sla_status
    SlaTicket.create!(
      ticket: id,
      sla_status: sla_status
    )
  end

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
      start_time = start_time.change(hour: 14, min: 0) if start_time.hour == 13
      # Skip time after 5pm
      start_time = start_time.change(hour: 8, min: 0) + 1.day if start_time.hour >= 17
      # Skip non-business days (Sunday)
      start_time = start_time.change(hour: 8, min: 0) + 1.day if start_time.wday.zero?
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
      end_time = end_time.change(hour: 14, min: 0) if end_time.hour == 13
      # Skip time after 5pm
      end_time = end_time.change(hour: 8, min: 0) + 1.day if end_time.hour >= 17
      # Skip non-business days (Sunday)
      end_time = end_time.change(hour: 8, min: 0) + 1.day if end_time.wday.zero?
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
