json.user do
  json.call @user, :id, :email, :locked_at
  json.role @user.role.name
  json.fullname @user.fullname
end
