# app/models/defects_user.rb
class DefectsUser < ApplicationRecord
  belongs_to :defect
  belongs_to :user
end
