class Bug < ApplicationRecord
  belongs_to :product
  belongs_to :task
  belongs_to :user
  has_one_attached :video

end
