class Bug < ApplicationRecord
  belongs_to :product
  belongs_to :user
  has_rich_text :content
  has_many_attached :video
  belongs_to :software, optional: true
  belongs_to :groupware, optional: true

  has_many :add_bugs, dependent: :destroy
  has_many :users, through: :add_bugs, dependent: :destroy

  has_many :status_bugs, dependent: :destroy
  has_many :statuses, through: :status_bugs, dependent: :destroy

  has_many_attached :images
end
