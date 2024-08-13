class Ticket < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_rich_text :body
  has_one_attached :image

  def self.search(query)
    return all if query.blank?

    where('priority LIKE ?', "%#{query}%")
  end
end
