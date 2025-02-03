class Bug < ApplicationRecord
  belongs_to :product
  belongs_to :user
  has_rich_text :content
  has_one_attached :video
  belongs_to :software, optional: true

  has_many :add_bugs, dependent: :destroy
  has_many :users, through: :add_bugs, dependent: :destroy
end
