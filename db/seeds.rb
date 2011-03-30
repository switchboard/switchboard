# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
user = User.find_or_create_by_login(:login => 'admin', :password => 'admin!', :password_confirmation => 'admin!', :email => 'foo@bar.com', :admin => 1)
user.save!

# create initial message states
MessageState.find_or_create_by_name('outgoing');
MessageState.find_or_create_by_name('incoming');
MessageState.find_or_create_by_name('handled');
MessageState.find_or_create_by_name('sent');
MessageState.find_or_create_by_name('error_incoming');
MessageState.find_or_create_by_name('error_outgoing');
