class Task < ApplicationRecord
  belongs_to :product
  belongs_to :user
  belongs_to :board
end
