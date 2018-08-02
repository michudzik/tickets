jQuery(document).on('turbolinks:load', function() {
  var inputColorChanged = false;
  $("#ticket_title").on('keyup', function() {
    if($(this).val().length >= 50){
      $(this).css("border-color", "red");
      $(this).css("box-shadow", "red 0px 0px 0px 1.6px");
      inputColorChanged = true;
    } else {
      if(inputColorChanged) {
        $(this).css("border-color", "#80bdff");
        $(this).css("box-shadow", "rgba(0, 123, 255, 0.25) 0px 0px 0px 3.2px");
      }
    }
  });
});