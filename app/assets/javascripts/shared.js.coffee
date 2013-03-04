window.sb = {

}

countMessageBody = (textarea) ->
  charcount = textarea.value.length;
  if (charcount > 140)
    textarea.value = textarea.value.substring(0, 140);
  else 
    $('#character_count').text(charcount + " / 140");


$(document).ready () ->
  # Linked tables: entire row does default action, which is the link marked '.clk' (usually on the first cell).
  # Good UX!
  $('table.linked tbody').on('click', 'tr', (e) ->
    return true if e.target.nodeName.toUpperCase() == 'A' || $(e.target).parent()[0].nodeName.toUpperCase() == 'A'
    window.location = $(this).addClass('clicked').find('a.clk').attr('href')
  )
