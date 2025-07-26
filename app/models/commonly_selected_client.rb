class CommonlySelectedClient < ApplicationRecord
  # Association for the commonly selected clients in thecease fire
  belongs_to :user
  belongs_to :client

  # Validations to ensure that no two records of the same client are input in the resource
  validates :client_id, uniqueness: { scope: :user_id, message: 'is already in your common list' }
end
