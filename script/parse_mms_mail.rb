#!/usr/bin/ruby  
require 'rubygems'
  require 'mms2r'
  mail = MMS2R.parse STDIN.read
  mms = MMS2R::Media.new(mail)
  subject = mms.subject
  number = mms.number
  file = mms.default_media
  text = mms.default_text


puts "mail had some text: #{file.inspect}" unless file.nil?
  text = IO.readlines(mms.media['text/plain'].first).join
  message = number + ": " + text + "\n"

filename = "/tmp/mms_received"
File.open(filename, "a" ) {|f| f.write(message) }
