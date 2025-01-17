class Client < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :projects, dependent: :nullify
  has_many :products, dependent: :nullify

  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
end
