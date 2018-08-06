# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user_role = Role.find_or_create_by({ name: 'user' })
it_support_role = Role.find_or_create_by({ name: 'it_support' })
om_support_role = Role.find_or_create_by({ name: 'om_support' })
admin_role = Role.find_or_create_by({ name: 'admin' })

admin = User.create(first_name: 'admin', last_name: 'admin', email: 'admin@admin.com', password: 'secret', confirmed_at: DateTime.now, role_id: admin_role.id)
it_support = User.create(first_name: 'it', last_name: 'support', email: 'itsupport@example.com', password: 'secret', confirmed_at: DateTime.now, role_id: it_support_role.id)
om_support = User.create(first_name: 'admin', last_name: 'admin', email: 'omsupport@example.com', password: 'secret', confirmed_at: DateTime.now, role_id: om_support_role.id)
user = User.create(first_name: 'admin', last_name: 'admin', email: 'user@example.com', password: 'secret', confirmed_at: DateTime.now, role_id: user_role.id)

it_department = Department.find_or_create_by({ name: 'IT' })
om_department = Department.find_or_create_by({ name: 'OM' })

status_open = Status.find_or_create_by({ name: 'open' }) 
status_closed = Status.find_or_create_by({ name: 'closed' })
status_user_response = Status.find_or_create_by({ name: 'user_response' })
status_support_response = Status.find_or_create_by({ name: 'support_response' })

Ticket.create(title: Faker::Name.name, note: Faker::Lorem.sentences(3).join(''), user_id: admin.id, department_id: it_department.id, status_id: status_open.id)
Ticket.create(title: Faker::Name.name, note: Faker::Lorem.sentences(3).join(''), user_id: it_support.id, department_id: om_department.id, status_id: status_user_response.id)
Ticket.create(title: Faker::Name.name, note: Faker::Lorem.sentences(3).join(''), user_id: om_support.id, department_id: it_department.id, status_id: status_closed.id)
Ticket.create(title: Faker::Name.name, note: Faker::Lorem.sentences(3).join(''), user_id: user.id, department_id: it_department.id, status_id: status_support_response.id)
