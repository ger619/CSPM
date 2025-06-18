class RemoveProductIdFromBugs < ActiveRecord::Migration[7.2]
  def change
    remove_reference :bugs, :product, null: false, foreign_key: true, type: :uuid
  rescue StandardError => e
    puts "Error removing product_id from bugs: #{e.message}"
  else
    puts "Successfully removed product_id from bugs"
  end
end

