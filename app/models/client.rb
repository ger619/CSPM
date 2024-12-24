class Client < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :products, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
end
