// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function highlightList(id) {
  // clear all classes from ids like list_id_N ???
  $$('.active_list').collect(function(s) {
    s.setAttribute("class", "");
  });
  var list = $(id);
  //return unless list;
  list.setAttribute("class", "active_list");
}

function countMessageBody(id) {
    if (!$(id)) return;
    var textarea = $(id);
    charcount = textarea.value.length;
    if (charcount > 140) {
       textarea.value = textarea.value.substring(0, 140);
    }else {
      var counter = $('character_count');
      counter.innerHTML = charcount+" / 140";
    }
}

document.observe("dom:loaded", function() {
  // the element in which we will observe all clicks and capture
  // ones originating from pagination links
  var container = $(document.body)

  if (container) {
    var img = new Image
    img.src = '/images/spinner.gif'

    function createSpinner() {
      return new Element('img', { src: img.src, 'class': 'spinner' })
    }

    container.observe('click', function(e) {
      var el = e.element()
      if (el.match('.pagination a')) {
        el.up('.pagination').insert(createSpinner())
        new Ajax.Request(el.href, { method: 'get' })
        e.stop()
      }
    })
  }
})

