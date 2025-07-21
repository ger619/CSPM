class RemoveTopicFromTasks < ActiveRecord::Migration[7.2]
  def change
    remove_column :tasks, :topic, :string
  end
end
