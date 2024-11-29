class Software < ApplicationRecord
  belongs_to :user
  has_many :products
  has_many :projects, dependent: :nullify
  has_many :groupwares, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
end
