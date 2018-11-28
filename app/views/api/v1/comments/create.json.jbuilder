json.comment do
  json.call @comment, :id, :body

  json.user do
    json.id @comment.user.id
    json.author @comment.user.fullname
    json.email @comment.user.email
  end

  json.ticket do
    json.id @comment.ticket.id
  end
end
