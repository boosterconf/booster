$('<%= escape_javascript(render(:partial => @review))%>')
  .prependTo('#all-reviews')
  .hide()
  .fadeIn()

$('#new-review').find('input:text, textarea').val('')