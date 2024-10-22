class AddUseridToComments < ActiveRecord::Migration[7.2]
  def change
    add_reference :comments, :user,  foreign_key: true, type: :uuid
    remove_column :comments, :solution, :string
  end
end
