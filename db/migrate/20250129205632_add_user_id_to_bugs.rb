class AddUserIdToBugs < ActiveRecord::Migration[7.2]
  def change
    add_reference :bugs, :user, type: :uuid, foreign_key: true
      end
end
