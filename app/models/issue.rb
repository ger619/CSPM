class Issue < ApplicationRecord
  belongs_to :ticket
  belongs_to :project
  belongs_to :user

  has_rich_text :content
end
