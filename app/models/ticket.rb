class Ticket < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_one_attached :ticket_image
  has_many :issues, dependent: :destroy

  has_rich_text :body
  has_one_attached :image

  validate :content_length_within_limit

  private

  def content_length_within_limit
    max_length = 800 # Set your desired character limit
    return unless body.to_plain_text.length > max_length

    errors.add(:body, "cannot be longer than #{max_length} characters.")
  end
end
