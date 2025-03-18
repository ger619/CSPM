class Client < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :projects, dependent: :nullify
  has_many :products, dependent: :nullify

  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }

  def users_count
    User.where(client_id: id).count
  end

  def projects_count
    Project.where(client_id: id).count
  end
end
