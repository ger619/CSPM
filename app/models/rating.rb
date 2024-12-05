class Rating < ApplicationRecord
  belongs_to :ticket
  belongs_to :user
  has_rich_text :content

  validates :value, presence: true, inclusion: { in: 1..5 }
end
