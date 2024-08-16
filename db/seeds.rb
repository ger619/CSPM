# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# Create Roles on the system

roles = ['Admin', 'Project Manager', 'Developer', 'QA', 'Agent']

roles.each do |role|
  # Role.find_or_create_by!(name: role)
    Role.create!(name: client) unless Role.exists?(name: client)
   Role.create!(name: admin) unless Role.exists?(name: admin)
end