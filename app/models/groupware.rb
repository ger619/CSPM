class Groupware < ApplicationRecord
  belongs_to :software, dependent: :destroy
end
