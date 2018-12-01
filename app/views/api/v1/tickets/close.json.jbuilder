json.ticket do
  json.call @ticket, :id, :title, :note
  json.status @ticket.status.name
  json.department @ticket.department.name
end
