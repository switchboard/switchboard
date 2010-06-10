require 'rubygems'
require 'tmail'
require 'mms2r'
file = 'message'
mail = TMail::Mail.parse(IO.read(file))
mms = MMS2R::Media.new(mail)
subject = mms.subject
plain_text_body = mms.body
# Get a file handle that can be
# passed to attachment_fu
default_file = mms.default_media
# <File:/tmp/topfunky/mms2r/book-screen-preview.png>
# This returns the temporary path to the image
png_path = mms.media['image/png'].first
# /tmp/topfunky/mms2r/book-screen-preview.png
# Other paths to media are available by type
media_types_hash = mms.media
# {'text/plain' => ..., 'image/png' => ...}

puts plain_text_body
