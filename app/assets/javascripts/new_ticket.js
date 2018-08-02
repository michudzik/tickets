var message = 'Are you sure you want to leave?'

$(document).on('turbolinks:load', function(){
  var form = $('#new_ticket'),
     original = form.serialize()

  form.submit(function(){
     window.onbeforeunload = null
  })

  window.onbeforeunload = function(){
     if (form.serialize() != original)
         return message
  }
});