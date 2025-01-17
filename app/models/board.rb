class Board < ApplicationRecord
  belongs_to :product
  belongs_to :user
  has_many :tasks, dependent: :nullify

  resourcify
  # To ensure that the ticket are connected to the user and their roles well defined
  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :users

  validates :status, presence: true
  validate :unique_status_per_board

  private

  def unique_status_per_board
    return unless Board.where(product_id:, status:).exists?

    errors.add(:status, 'must be unique per board')
  end
end
