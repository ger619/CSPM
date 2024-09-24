class Product < ApplicationRecord
  belongs_to :user

  has_rich_text :content
  has_many_attached :images

  resourcify
  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :admin }) }, class_name: 'User', through: :roles, source: :users
end
