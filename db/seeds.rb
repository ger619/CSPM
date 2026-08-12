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

Role.find_or_create_by!(name: 'agent')
Role.find_or_create_by!(name: 'admin')
Role.find_or_create_by!(name: 'project manager')
Role.find_or_create_by!(name: 'client')
Role.find_or_create_by!(name: 'observer')
Role.find_or_create_by!(name: 'sales')
Role.find_or_create_by!(name: 'ceo')
Role.find_or_create_by!(name: 'hod')

a = User.create!(email: 'admin@greatercare.com', password: 'password', confirmed_at: DateTime.now , confirmation_sent_at: DateTime.now, first_name: 'Jay', last_name: 'Admin')
a.add_role(:admin)

b = User.create!(email: 'project@greatercare.com', password: 'password', confirmed_at: DateTime.now , confirmation_sent_at: DateTime.now, first_name: 'Project', last_name: 'Manager')
b.add_role('project manager')

c = User.create!(email: 'agent@greatercare.com', password: 'password', confirmed_at: DateTime.now , confirmation_sent_at: DateTime.now, first_name: 'Agent', last_name: 'Active')
c.add_role(:agent)

d = User.create!(email: 'client@greatercare.com', password: 'password', confirmed_at: DateTime.now , confirmation_sent_at: DateTime.now, first_name: 'Client', last_name: 'Active')
d.add_role(:client)
admin = User.find_by!(email: 'admin@greatercare.com')



Client.create!(name: 'Greater Care', email: 'client@greatercare.com', user_id: User.find_by(email: 'admin@greatercare.com').id)

Software.create!(name: 'Greater Care', user_id: User.find_by(email: 'project@greatercare.com').id)
Groupware.create!(name: 'Greater Care', software_id: Software.find_by(name: 'Greater Care').id, user_id: User.find_by(email: 'admin@greatercare.com').id)

statuses = %w[Decline Accept Pending Approved Assigned On-Hold Completed In-Progress Rejected Cancelled Closed]

statuses.each do |status_name|
  Status.find_or_create_by!(name: status_name) do |status|
    status.user_id = admin.id
  end
end