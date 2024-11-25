class Software < ApplicationRecord
  belongs_to :user
  has_many :products
  has_many :projects
  has_many :groupwares

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
end
