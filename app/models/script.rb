class Script < ApplicationRecord
  belongs_to :groupware
  belongs_to :software
  has_and_belongs_to_many :products

  validates :name, presence: true
  validates :description, presence: true
end
