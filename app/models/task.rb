class Task < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_one_attached :image
  has_one_attached :file
  has_many :messages, dependent: :destroy
  before_create :set_default_state
  # app/models/task.rb

  belongs_to :prerequisite_task, class_name: 'Task', foreign_key: 'tasks_id', optional: true
  resourcify

  has_many :role_users, through: :roles, class_name: 'User', source: :user
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :user

  validate :end_date_after_start_date
  validate :image_must_be_an_image
  validate :file_must_be_a_file
  validate :prerequisite_task_must_be_resolved, on: :update

  has_many :add_tasks
  has_many :users, through: :add_tasks, dependent: :destroy
  has_and_belongs_to_many :statuses, dependent: :destroy
  has_many :bugs
  has_rich_text :description
  scope :for_product, ->(product_id) { where(product_id: product_id) }

  def set_default_state
    status = Status.find_by(name: 'TO DO')
    statuses << status if status
  end

  def self.prerequisite_tasks(product_id)
    resolved_status = Status.find_by(name: 'Resolved')
    if resolved_status
      joins(:statuses)
        .where(product_id: product_id)
        .where.not(statuses: { id: resolved_status.id })
        .distinct
    else
      where(product_id: product_id)
    end
  end

  # if task has a prerequisite task, the prerequisite task should have status resolved
  # if not it one should not be able to update status
  def prerequisite_task_must_be_resolved
    return unless prerequisite_task.present?

    return if prerequisite_task.statuses.exists?(name: 'Resolved')

    errors.add(:base, "Prerequisite task must be resolved before updating this task's status.")
  end

  private

  def end_date_after_start_date
    return unless end_date.present? && start_date.present? && end_date < start_date

    errors.add(:end_date, 'End Date must be greater than Start Date')
  end

  # Ensure uploaded image is an actual image
  def image_must_be_an_image
    return unless image.attached?

    return if image.content_type.starts_with?('image/')

    errors.add(:image, 'must be an image file (jpeg, jpg, gif, or png).')
  end

  # Ensure uploaded file is a generic valid file
  def file_must_be_a_file
    return unless file.attached?

    return if file.content_type.start_with?('application/') || file.content_type.start_with?('text/')

    errors.add(:file, 'must be a valid file (pdf, doc, txt, etc.).')
  end
end
