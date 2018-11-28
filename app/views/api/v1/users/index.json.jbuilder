json.users @users do |user|
  json.call user, :id, :email, :locked_at
  json.fullname user.fullname
  json.role user.role.name
end
