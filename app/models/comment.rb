class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :ticket
  has_rich_text :content

  private

  def content_length_within_limit
    return unless content.to_plain_text.length > 200

    errors.add(:content, 'must be less than or equal to 200 characters')
  end
end
