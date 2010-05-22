  require 'rubygems'
  require 'mms2r'
  mail = Mail.read("message")
  mms = MMS2R::Media.new(mail)
  subject = mms.subject
  number = mms.number
  file = mms.default_media
  text = mms.default_text


puts subject
puts number
puts file

puts "mail had some text: #{file.inspect}" unless file.nil?
  text = IO.readlines(mms.media['text/plain'].first).join
  puts text


  mms.purge
