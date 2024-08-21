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

Role.create!([name: 'agent'])
Role.create!([name: 'admin'])
Role.create!([name: 'project manager'])
Role.create!([name: 'client'])

c = User.create!(email: 'abolger254@gmai.com', password: 'password')
c.add_role(:admin)
c.confirmation_token = true