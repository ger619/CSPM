class Board < ApplicationRecord
  belongs_to :product
  belongs_to :user


  resourcify
  # To ensure that the ticket are connected to the user and their roles well defined
  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :users
end
