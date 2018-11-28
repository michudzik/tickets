json.call @ticket, :id, :title, :note, :created_at, :updated_at
json.department @ticket.department.name
json.status @ticket.status.name

json.user do
  json.id @ticket.user.id
  json.author @ticket.user.fullname
  json.role @ticket.user.role.name
end

json.comments @comments do |comment|
  json.call comment, :id, :body, :created_at

  json.user do
    json.id comment.user.id
    json.author comment.user.fullname
  end
end
