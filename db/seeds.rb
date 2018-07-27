# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

['user', 'it_support', 'om_support', 'admin'].each do |role|
  Role.find_or_create_by({ name: role })
end

admin_role = Role.find_by(name: 'admin')
User.create(first_name: 'admin', last_name: 'admin', email: 'admin@admin.com', password: 'secret', confirmed_at: DateTime.now, role_id: admin_role.id)

['IT', 'OM'].each do |department|
  Department.find_or_create_by({ name: department })
end

['open', 'support_response', 'user_response', 'closed'].each do |status|
  Status.find_or_create_by({ name: status })
end
