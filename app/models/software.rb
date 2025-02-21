class Software < ApplicationRecord
  belongs_to :user
  # has_many :products
  has_and_belongs_to_many :projects, dependent: :nullify
  has_and_belongs_to_many :products, dependent: :nullify
  has_many :groupwares, dependent: :nullify

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
end
