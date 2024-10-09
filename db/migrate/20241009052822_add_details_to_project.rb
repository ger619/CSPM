class AddDetailsToProject < ActiveRecord::Migration[7.2]
  def change
    add_reference :projects, :client, null: false, foreign_key: true, type: :uuid
    add_reference :projects, :software, null: false, foreign_key: true, type: :uuid
  end
end
