class AddStatus < ApplicationRecord
  belongs_to :ticket
  belongs_to :status
end
