class Switchboard.ListController extends Spine.Controller
  el: 'body'

  events:
    'change #list_use_welcome_message': 'checkWelcomeMmessage'
    'keyup #list_name': 'capitalizeListName'
    'change #list_name': 'checkListName'
    'change input': 'toggleConfirmationDisplay'

  constructor: ->
    super
    @checkWelcomeMmessage()
    @toggleAnnouncementConfig()

  checkWelcomeMmessage: (e) ->
    $welcome_div = $('#welcome_message_wrap')
    if $welcome_div.length > 0
      if $('#list_use_welcome_message').is(':checked')
        $welcome_div.show()
      else
        $welcome_div.hide()

  capitalizeListName: (e) ->
    $name = $(e.target)
    name = $name.val().replace(' ', '').toUpperCase()
    if name != $name.val()
      $name.val(name)
      $name.trigger('change')

  checkListName: (e) ->
    list_name = $(e.target).val()
    if(list_name.length > 0)
      $.ajax(
        url: Switchboard.urls.check_list_availability
        data: {name: list_name}
        success: @checkListNameOk
      )
    else
      $('#availability').html('')

  checkListNameOk: (data, status, jqxhr) ->
    $('#availability').html(data)
    $('.input.list_name').removeClass('field_with_errors').find('span.error').remove()

  toggleAnnouncementConfig: ->
    $('#announcement_list_wrap').toggle($('#list_all_users_can_send_messages_false').is(':checked'))