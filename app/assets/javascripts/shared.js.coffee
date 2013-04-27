window.Switchboard = {
  urls:
    check_list_availability: '/lists/check_name_available'

  countMessageBody: (textarea) ->
    max = 160
    metadata_length = $(textarea).data('meta-length')
    max = max - metadata_length if metadata_length
    charcount = textarea.value.length;
    if (charcount > max)
      textarea.value = textarea.value.substring(0, max)
    else
      $('#character_count').text("#{charcount} / #{max}")

}

$(document).ready () ->
  # Linked tables: entire row does default action, which is the link marked '.clk' (usually on the first cell).
  # Good UX!
  $('table.linked tbody').on('click', 'tr', (e) ->
    nodename = e.target.nodeName.toUpperCase()
    return true if nodename == 'A' || nodename == 'INPUT' || $(e.target).parent()[0].nodeName.toUpperCase() == 'A'
    window.location = $(this).addClass('clicked').find('a.clk').attr('href')
  )

  $('textarea.count_characters').on('keyup', (e) ->
    Switchboard.countMessageBody(this)
  )
