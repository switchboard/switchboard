class Switchboard.ListController extends Spine.Controller
  el: 'body'

  events:
    'change #list_use_welcome_message': 'check_welcome_message'
    'keyup #list_name': 'capitalize_list_name'
    'change #list_name': 'check_list_name'

  constructor: ->
    super
    @check_welcome_message()

  check_welcome_message: (e) ->
    $welcome_div = $('#welcome_message_wrap')
    if $welcome_div.length > 0
      if $('#list_use_welcome_message').is(':checked')
        $welcome_div.show()
      else
        $welcome_div.hide()

  capitalize_list_name: (e) ->
    $name = $(e.target)
    name = $name.val().replace(' ', '').toUpperCase()
    if name != $name.val()
      $name.val(name)
      $name.trigger('change')
  check_list_name: (e) ->
    list_name = $(e.target).val()
    if(list_name.length > 0)
      $.ajax(
        url: Switchboard.urls.check_list_availability 
        data: {name: list_name}
        success: @check_list_name_ok
      )
    else
      $('#availability').html('')
  
  check_list_name_ok: (data, status, jqxhr) ->
    $('#availability').html(data)
    $('.input.list_name').removeClass('field_with_errors').find('span.error').remove()
