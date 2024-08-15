class Ticket < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_one_attached :ticket_image
  # belongs_to :parent, class_name: 'Ticket', optional: true
  # has_many :ticket, class_name: 'Ticket', foreign_key: 'parent_id', dependent: :destroy
  has_many :issues, dependent: :destroy

  has_rich_text :body
  has_one_attached :image
end
