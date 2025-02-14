class Status < ApplicationRecord
  has_many :add_statuses
  has_many :tickets, through: :add_statuses, dependent: :destroy
  has_many :status_bugs
  has_many :bugs, through: :status_bugs, dependent: :destroy
end
