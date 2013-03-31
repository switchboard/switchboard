# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

admin = Contact.create! do |u|
  u.login = 'admin'
  u.password = 'admin!'
  u.password_confirmation = 'admin!'
  u.email = 'admin@changeme.com'
  u.admin = 1
end
admin.save! 

# create initial message states
MessageState.find_or_create_by_name('outgoing');
MessageState.find_or_create_by_name('incoming');
MessageState.find_or_create_by_name('handled');
MessageState.find_or_create_by_name('sent');
MessageState.find_or_create_by_name('error_incoming');
MessageState.find_or_create_by_name('error_outgoing');
