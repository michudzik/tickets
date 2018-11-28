json.tickets @tickets do |ticket|
  json.call ticket, :id, :title, :updated_at
  json.author ticket.user.fullname
  json.status ticket.status.name
  json.department ticket.department.name
end
