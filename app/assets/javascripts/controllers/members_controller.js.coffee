class Switchboard.MembersController extends Spine.Controller
  el: 'body'
  elements:
    '#search_q': 'search_field'
    'form.search_form': 'search_form'
    '#member_list_wrap': 'results'
  events:
    'submit .search_form': 'doSearch'

  constructor: ->
    super
    @form_url = @search_form.attr('action')
    @watchSearch()
    @watchAdminCheckboxes()

  watchSearch: ->
    input_event = Switchboard.whichInputEvent()
    @search_field.on(input_event, @onSearchChange)

  onSearchChange: (e) =>
    timeout = 300

    clearTimeout(@searching)
    @searching = setTimeout( =>
      @doSearch() if @term != @search_field.val()
    , timeout)

  doSearch: (e) =>
    e.preventDefault() if e
    @term = @search_field.val()
    url_data = {q: @term}
    submit_url = @form_url + '?xhr=1&' + $.param(url_data)
    @results.fadeTo(200, 0.5).load(submit_url,  =>
      @results.fadeTo(200, 1)
    )

  watchAdminCheckboxes: ->
    @results.on('change', '.adminToggle', (e) ->
      $checkbox = $(e.target)
      $wrap = $checkbox.closest('div')
      user_id = $checkbox.data('phone')
      list_id = $checkbox.data('list')
      $wrap.addClass('saving')
      $.ajax
        url: "/lists/#{list_id}/toggle_admin"
        data: "list_member_id=#{user_id}"
        success: ->
          $checkbox.siblings('img').hide()
          $wrap.removeClass('saving')
    )
