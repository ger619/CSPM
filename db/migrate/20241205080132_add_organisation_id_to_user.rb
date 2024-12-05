class AddOrganisationIdToUser < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :organisation, foreign_key: true, type: :uuid
  end
end
