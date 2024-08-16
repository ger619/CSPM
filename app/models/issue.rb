class Issue < ApplicationRecord
  belongs_to :ticket
  belongs_to :project
  belongs_to :user

  has_rich_text :content

  resourcify

  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :creator }) }, class_name: 'User', through: :roles, source: :users
end
