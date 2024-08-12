class Ticket < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_rich_text :body

  def self.search(query)
    return all if query.blank?

    where('priority LIKE ?', "%#{query}%")
  end
end
