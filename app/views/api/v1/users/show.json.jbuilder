json.call @user, :email, :fullname
json.role @user.role.name

json.tickets @tickets do |ticket|
  json.call ticket, :id, :title
  json.status ticket.status.name
  json.department ticket.department.name
end
