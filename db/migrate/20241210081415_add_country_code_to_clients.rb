class AddCountryCodeToClients < ActiveRecord::Migration[7.2]
  def change
    add_column :clients, :country_code, :string
  end
end
