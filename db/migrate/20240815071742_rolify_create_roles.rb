class RolifyCreateRoles < ActiveRecord::Migration[7.1]
  def change
    # Creating roles table with UUID as primary key
    create_table(:roles, id: :uuid) do |t|
      t.string :name
      t.references :resource, polymorphic: true, type: :uuid  # Use UUID for resource_id

      t.timestamps
    end

    # Creating join table between users and roles with UUID references
    create_table(:users_roles, id: false) do |t|
      t.references :user, type: :uuid  # Use UUID for user_id
      t.references :role, type: :uuid  # Use UUID for role_id
    end

    # Adding indexes
    add_index(:roles, [:name, :resource_type, :resource_id], unique: true)
    add_index :roles, :name, unique: true
    add_index(:users_roles, [:user_id, :role_id])
  end
end
