class Task < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :board
  has_one_attached :image

  resourcify

  has_many :role_users, through: :roles, class_name: 'User', source: :user
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :user
end
