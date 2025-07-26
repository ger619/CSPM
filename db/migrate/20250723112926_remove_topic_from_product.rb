class RemoveTopicFromProduct < ActiveRecord::Migration[7.2]
  def change
    remove_column :products, :topic, :string
  end
end
