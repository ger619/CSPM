class Defect < ApplicationRecord
  has_many :defects_users
  has_many :users, through: :defects_users
  # has_and_belongs_to_many :users, join_table: :defects_users

  belongs_to :product
  has_many :bugs, dependent: :destroy

  resourcify
  has_many :users, through: :roles, class_name: 'User', source: :users
  has_many :creators, -> { where(roles: { name: :admin }) }, class_name: 'User', through: :roles, source: :users
  has_many :editors, lambda {
    where(roles: { name: ['admin', 'project manager'] })
  }, class_name: 'User', through: :roles, source: :users
end
