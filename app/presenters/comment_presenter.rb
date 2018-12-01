class CommentPresenter < BasePresenter
  present :comment

  def created_at
    comment.created_at.strftime('%H:%M')
  end

  def created_at_tooltip
    comment.created_at.strftime('%A, %Y.%m.%d, %H:%M')
  end

  def body
    comment.body.gsub(/\n/, '<br />')
  end

  def shortened_comment
    "(#{created_at}): #{truncated_body}"
  end

  def author
    "#{comment.user.fullname} (#{comment.user.role.name.humanize})"
  end

  private

  def truncated_body
    body.truncate(40, omission: '... (continued)')
  end
end
