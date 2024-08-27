class Assignee < ApplicationRecord
  belongs_to :project
  belongs_to :user
  belongs_to :ticket
end
