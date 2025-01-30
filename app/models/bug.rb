class Bug < ApplicationRecord
  belongs_to :task
  belongs_to :user
  has_rich_text :content
  has_one_attached :video
end
