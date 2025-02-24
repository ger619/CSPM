class Groupware < ApplicationRecord
  belongs_to :software
  has_many :scripts, dependent: :nullify
  belongs_to :user
  has_many :tickets, dependent: :nullify
  has_many :bugs, dependent: :nullify
end
