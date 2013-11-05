class AddFullNameToContacts < ActiveRecord::Migration
  # Preventing broken migrations
  class Contact < ActiveRecord::Base
  end

  def up
    add_column :contacts, :full_name, :string

    Contact.find_each do |contact|
      contact.update_column(:full_name, [contact.first_name, contact.last_name].join(' ').strip)
    end

  end

  def down
    remove_column :contacts, :full_name
  end
end