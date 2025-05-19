class Bug < ApplicationRecord
  belongs_to :product
  belongs_to :user
  has_rich_text :content
  belongs_to :software, optional: true
  belongs_to :groupware, optional: true
  belongs_to :script, optional: true

  has_many :add_bugs, dependent: :destroy
  has_many :users, through: :add_bugs, dependent: :destroy

  has_many :status_bugs, dependent: :destroy
  has_many :statuses, through: :status_bugs, dependent: :destroy

  has_many_attached :images
  has_many_attached :videos

  before_create :set_default_status

  def set_default_status
    status = Status.find_by(name: 'TO DO')
    statuses << status if status
  end
end
