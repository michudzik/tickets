json.ticket do
  json.call @ticket, :id, :title
  json.author @ticket.user.fullname
  json.department @ticket.department.name
  json.status @ticket.status.name
end
