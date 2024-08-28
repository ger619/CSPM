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

a = User.create!(email: 'admin@craft.com', password: 'password', confirmed_at: DateTime.now , confirmation_sent_at: DateTime.now, first_name: 'Jay', last_name: 'Admin')
a.add_role(:admin)

b = User.create!(email: 'project@craft.com', password: 'password', confirmed_at: DateTime.now , confirmation_sent_at: DateTime.now, first_name: 'User', last_name: 'User')
b.add_role('project manager')

c = User.create!(email: 'agent@craft.com', password: 'password', confirmed_at: DateTime.now , confirmation_sent_at: DateTime.now, first_name: 'User', last_name: 'User')
c.add_role(:agent)

d = User.create!(email: 'client@craft.com', password: 'password', confirmed_at: DateTime.now , confirmation_sent_at: DateTime.now, first_name: 'User', last_name: 'User')
d.add_role(:client)