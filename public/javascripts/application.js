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
