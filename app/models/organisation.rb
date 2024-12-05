class Organisation < ApplicationRecord
  has_many :users, dependent: :destroy
end
