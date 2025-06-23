class Task < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :board
  has_one_attached :image
  has_one_attached :file
  has_many :messages, dependent: :destroy

  resourcify

  has_many :role_users, through: :roles, class_name: 'User', source: :user
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :user

  validate :end_date_after_start_date
  validate :image_must_be_an_image
  validate :file_must_be_a_file

  has_many :add_tasks
  has_many :users, through: :add_tasks, dependent: :destroy
  has_many :bugs

  private

  def end_date_after_start_date
    return unless end_date.present? && start_date.present? && end_date < start_date

    errors.add(:end_date, 'End Date must be greater than Start Date')
  end

  # Ensure uploaded image is an actual image
  def image_must_be_an_image
    return unless image.attached?

    unless image.content_type.starts_with?("image/")
      errors.add(:image, "must be an image file (jpeg, jpg, gif, or png).")
    end
  end

  # Ensure uploaded file is a generic valid file
  def file_must_be_a_file
    return unless file.attached?

    unless file.content_type.start_with?("application/") || file.content_type.start_with?("text/")
      errors.add(:file, "must be a valid file (pdf, doc, txt, etc.).")
    end
  end
end
