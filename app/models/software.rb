class Software < ApplicationRecord
  belongs_to :user
  has_many :products
  has_many :projects
end
