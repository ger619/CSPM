class Client < ApplicationRecord
  belongs_to :user
  has_many :projects
  has_many :products

  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
end
