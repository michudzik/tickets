const ActionCable = require('actioncable-modules');
 
let actionCable = ActionCable.createConsumer();

$(document).on('turbolinks:load', function() {
  var comments;
  comments = $('.commentSection');
  if ($('.commentSection').length > 0) {
    return actionCable.subscriptions.create({
      channel: "CommentsChannel",
      ticket_id: comments.data('ticket-id')
    }, {
      connected: function() {},
      disconnected: function() {},
      received: function(data) {
        return comments.append(data['body']);
      },
      send_comment: function(comment, ticket_id) {
        return this.perform('send_comment', {
          comment: comment,
          ticket_id: ticket_id
        });
      }
    });
  }
});
