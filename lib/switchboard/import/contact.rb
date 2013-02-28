module Switchboard
module Import
  ## Contact is a data object class, designed to store the values of a 'contact' record being imported or
  ## exported from another format
  class Contact
    attr_accessor :source, :source_id
    attr_accessor :first_name, :last_name
    attr_accessor :phone_number, :email

  end
end
end

