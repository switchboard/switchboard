#!/usr/bin/ruby  
require 'rubygems'
require 'net/http'

  require 'mms2r'
  mail = MMS2R.parse STDIN.read
  mms = MMS2R::Media.new(mail)
  subject = mms.subject
  number = mms.number
  file = mms.default_media
  text = mms.default_text
  carrier = mms.carrier
  to = mms.mail.to

puts "mail had some text: #{file.inspect}" unless file.nil?
  text = IO.readlines(mms.media['text/plain'].first).join
  message = number + ": " + text + "\n"

filename = "/tmp/mms_received"
File.open(filename, "a" ) {|f| f.write(message) }

res = Net::HTTP.post_form(URI.parse('http://localhost:3000/messages/email/create'), 
    { 'From' => number, 'Body' => text, 'To' => to } ); 
