class AddUniqueIdToIssues < ActiveRecord::Migration[7.2]
  def change
    add_column :issues, :unique_id, :string
    add_index :issues, :unique_id, unique: true
  end
end
