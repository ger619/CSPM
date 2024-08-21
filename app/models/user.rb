class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :lockable, :timeoutable, :trackable
  # To ensure that a user has at least one role
  has_one_attached :profile_picture
  # To ensure that a user has at least one role
  has_many :projects, foreign_key: :user_id, class_name: 'Project', dependent: :destroy
  has_many :tickets, foreign_key: :user_id, class_name: 'Ticket', dependent: :destroy
  has_many :issues, foreign_key: :user_id, class_name: 'Issue', dependent: :destroy
  # To ensure that a user has at least one role
  has_many :projects, through: :roles, source: :resource, source_type: :Project
  has_many :tickets, through: :roles, source: :resource, source_type: :Ticket
  has_many :issues, through: :roles, source: :resource, source_type: :Issue

  # To show which user invited a user

  has_many :invitees, class_name: 'User', foreign_key: :invited_by_id

  # To ensure that a user has at least one role
  after_create :assign_default_role
  # To ensure that a user has at least one role
  validate :must_have_a_role, on: :update

  def assign_default_role
    add_role(:agent) if roles.blank?
  end

  # To have a list of user who only have a specific role
  def self.with_agent_role
    joins(:roles).where(roles: { name: 'agent' })
  end

  # To ensure either the first name or last name is present and they appear in the initials
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

  after_initialize :set_default_profile_completed, if: :new_record?

  def set_default_profile_completed
    self.first_login ||= false
  end

  private

  def must_have_a_role
    return if roles.any?

    errors.add(:roles, 'must have at least one role')
  end
end
