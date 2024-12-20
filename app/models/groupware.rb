class Groupware < ApplicationRecord
  belongs_to :software, dependent: :destroy
  belongs_to :user

end
