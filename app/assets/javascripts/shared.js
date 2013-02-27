var countMessageBody = function(textarea) {

  charcount = textarea.value.length;

  if (charcount > 140) {
    textarea.value = textarea.value.substring(0, 140);
  } else {
    $('#character_count').text(charcount + " / 140");
  }
};


