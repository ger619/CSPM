class AddUniqueTrueToProduct < ActiveRecord::Migration[7.2]
  def change

    # This is the migration file for adding the unique constraint to the title column in the products table
    # The unique constraint will ensure that the title of the product is unique
    # This will prevent the creation of products with the same title
    # The unique constraint will be added to the title column in the products table
    # The unique constraint will be added to the title column in the products table
    add_index :products, :name, unique: true
  end
end
