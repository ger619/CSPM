class AddUserToGroupware < ActiveRecord::Migration[7.2]
  def change
    add_reference :groupwares, :user,  foreign_key: true, type: :uuid
  end
end
