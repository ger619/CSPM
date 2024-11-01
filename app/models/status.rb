class Status < ApplicationRecord
  has_many :add_statuses
  has_many :tickets, through: :add_statuses, dependent: :destroy
end
