class StatusBug < ApplicationRecord
  belongs_to :bug
  belongs_to :status
end
