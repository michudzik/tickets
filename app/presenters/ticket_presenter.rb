class TicketPresenter < BasePresenter
  present :ticket

  def department_name
    ticket.department.name
  end

  def created_at
    ticket.created_at.strftime('%k:%M %d-%m-%Y')
  end

  def last_response
    return ticket.comments.last.updated_at.strftime('%Y.%m.%d %H:%M') if ticket.comments.any?

    created_at
  end

  def status
    ticket.status.name.humanize
  end

  def author
    ticket.user.fullname
  end

  def note
    ticket.note.gsub(/\n/, '<br />')
  end
end
