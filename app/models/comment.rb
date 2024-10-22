class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :ticket
  has_rich_text :content

  private

  def content_length_within_limit
    return unless content.to_plain_text.length > 800

    errors.add(:content, 'must be less than or equal to 800 characters')
  end
end
