jQuery(document).on 'turbolinks:load', ->
  comments = $('.commentSection')
  if $('.commentSection').length > 0

    App.comments = App.cable.subscriptions.create {
      channel: "CommentsChannel",
      ticket_id: comments.data('ticket-id')
      },

      connected: ->
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        comments.append data['body']

      send_comment: (comment, ticket_id) ->
        @perform 'send_comment', comment: comment, ticket_id: ticket_id

    $('#new_comment').submit (e) ->
        $this = $(this)
        textarea = $this.find('#comment_body')
        if $.trim(textarea.val()).length > 1
          App.comments.send_comment textarea.val(), messages.data('chat-room-id')
          textarea.val('')
        e.preventDefault()
        return false