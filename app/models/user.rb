class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :lockable, :timeoutable, :trackable

  has_one_attached :profile_picture
  has_many :projects, foreign_key: :user_id, class_name: 'Project', dependent: :destroy
  has_many :tickets, foreign_key: :user_id, class_name: 'Ticket', dependent: :destroy
  has_many :issues, foreign_key: :user_id, class_name: 'Issue', dependent: :destroy

  has_many :projects, through: :roles, source: :resource, source_type: :Project

  after_create :assign_default_role

  validate :must_have_a_role, on: :update

  def assign_default_role
    add_role(:agent) if roles.blank?
  end

  def name_initials
    if first_name.present? && last_name.present?
      "#{first_name[0]}#{last_name[0]}"
    elsif first_name.present?
      first_name[0]
    elsif last_name.present?
      last_name[0]
    else
      blank?
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  private

  def must_have_a_role
    return if roles.any?

    errors.add(:roles, 'must have at least one role')
  end
end
