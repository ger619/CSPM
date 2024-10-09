class AddDetailsToProject < ActiveRecord::Migration[7.2]
  def change
    add_reference :projects, :client, foreign_key: true, type: :uuid
    add_reference :projects, :software,  foreign_key: true, type: :uuid
  end
end
