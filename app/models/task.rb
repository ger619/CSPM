class Task < ApplicationRecord
  belongs_to :product
  belongs_to :user
  belongs_to :board
  has_one_attached :image

  validate :end_date_after_start_date

  def end_date_after_start_date
    return unless end_date.present? && start_date.present? && end_date < start_date

    errors.add(:end_date, 'End Date must be greater than Start Date')
  end
end
