class Bug < ApplicationRecord
  belongs_to :task
  belongs_to :user
  has_rich_text :content
  has_one_attached :video

  has_many :add_bugs, dependent: :destroy
  has_many :users, through: :add_bugs, dependent: :destroy
end
