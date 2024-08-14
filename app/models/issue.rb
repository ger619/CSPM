class Issue < ApplicationRecord
  belongs_to :ticket
  belongs_to :project
  belongs_to :user
end
