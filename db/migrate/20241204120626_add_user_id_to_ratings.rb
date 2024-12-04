class AddUserIdToRatings < ActiveRecord::Migration[7.2]
  def change
    add_reference :ratings, :user, null: false, foreign_key: true, type: :uuid
  end
end
