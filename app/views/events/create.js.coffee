$('<%= escape_javascript(render(:partial => @event))%>')
  .prependTo('#comments')
  .hide()
  .fadeIn()

$('#new_comment').find('input:text, textarea').val('')