class CreateJoinTableProductGroupware < ActiveRecord::Migration[7.2]
  def change
    create_join_table :products, :groupwares, column_options: { type: :uuid } do |t|
       t.index [:product_id, :groupware_id]
       t.index [:groupware_id, :product_id]
    end
  end
end
