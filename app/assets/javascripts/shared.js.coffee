window.Switchboard = {
  urls:
    check_list_availability: '/lists/check_name_available'
  hasInputEvent: null
  countMessageBody: (textarea) ->
    max = 160
    metadata_length = $(textarea).data('meta-length')
    max = max - metadata_length if metadata_length
    charcount = textarea.value.length;
    if (charcount > max)
      textarea.value = textarea.value.substring(0, max)
    else
      $('#character_count').text("#{charcount} / #{max}")


  # Little dance to determine whether we can listen to input event; not bothering with keyup because it doesn't run on paste, causes confusion, plus, http://bugs.jquery.com/ticket/10818, and http://stackoverflow.com/questions/6382389/oninput-in-ie9-doesnt-fire-when-we-hit-backspace-del-do-cut
  # Note, in testing, IE9 does seem to fire input event just fine. Should revisit.
  whichInputEvent: () ->
    inputSupport = Switchboard.checkInputEvent()
    if inputSupport && ! this.isIe9()
      'input'
    else
      'change'

  checkInputEvent: () ->
    el = document.body
    # Caching result
    if window.Switchboard.hasInputEvent != null
      return window.Switchboard.hasInputEvent
    if "oninput" in el
      window.Switchboard.hasInputEvent = true
      return true

    # https://github.com/Modernizr/Modernizr/issues/210
    # First check, for if Firefox fixes its issue with el.oninput = function
    el.setAttribute("oninput", "return")
    if (typeof el.oninput == "function")
      window.Switchboard.hasInputEvent = true
      return true
    try
      e  = document.createEvent("KeyboardEvent")
      ok = false
      tester = (e) ->
        ok = true
        e.preventDefault()
        e.stopPropagation()
      e.initKeyEvent("keypress", true, true, window, false, false, false, false, 0, "e".charCodeAt(0))
      document.body.appendChild(el)
      el.addEventListener("input", tester, false)
      el.focus()
      el.dispatchEvent(e)
      el.removeEventListener("input", tester, false)
      document.body.removeChild(el)
      window.Switchboard.hasInputEvent = ok
      return ok
    catch e

  isIe8: () ->
    /MSIE\ 8/g.test(navigator.userAgent)
  isIe9: () ->
    /MSIE\ 9/g.test(navigator.userAgent)
}

$(document).ready () ->
  # Linked tables: entire row does default action, which is the link marked '.clk' (usually on the first cell).
  # Good UX!
  $('table.linked tbody').on('click', 'tr', (e) ->
    nodename = e.target.nodeName.toUpperCase()
    return true if nodename == 'A' || nodename == 'INPUT' || $(e.target).parent()[0].nodeName.toUpperCase() == 'A'
    if new_url = $(this).addClass('clicked').find('a.clk').attr('href')
      window.location = new_url
  )

  $('textarea.count_characters').on('keyup', (e) ->
    Switchboard.countMessageBody(this)
  )
