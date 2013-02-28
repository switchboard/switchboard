module Switchboard
module Import

  require "csv"
  require "contact.rb" 

  ## CsvImporter will currently import 5 fields from a CSV file:
  ## source_id (default: "Contant ID") -- unique identifier from source
  ## first_name (default: "First Name")
  ## last_name (default: "Last Name")
  ## phone_number (default: "Mobile Phone")
  ## email (default "Email")

  ## The importer expects an initial row of header labels to determine the index of each column.
  ## A hash of column headers can be passed in to the constructor to override the defaults, e.g.
  ## CsvImporter.new( { :email => "Email Address"  } ) 

  class CsvImporter
    # hash of symbols to field names, e.g. :email => "Email"
    attr_accessor :field_names
  
    # hash of symbols to column indexes, e.g. :email => 3
    attr_accessor :field_indexes

    # boolean to indicate success or failure
    attr_accessor :success

    attr_accessor :result_message

    ## array of result contact instances
    attr_accessor :contacts

    ## skipped rows
    attr_accessor :skipped_rows

    def initialize(field_names = {})
      default_map = { 
        :source_id => "Contact ID",
        :first_name => "First Name",
        :last_name => "Last Name",
        :phone_number => "Mobile Phone",
        :email => "Email"
      }
      self.field_names = default_map.merge(field_names)
      self.field_indexes = {} 

      self.field_names.each_key do |key|
        self.field_indexes[key] = -1
      end
      self.skipped_rows = 0
    end

    ## parse takes in a csv file and returns an array of Contact instances,
    ## which are light data objects to store the relevant contact information.
    ## 
    ## path: path to csv file to parse
    ## source: description string to indicate the source of the contact
    def parse(path, source)
      self.contacts = []
      self.success = true
      reader = CSV.open(path, 'r')
      header_row = reader.shift
      return unless find_column_indexes(header_row)
      
      reader.each do |columns| 
        c = Contact.new
        p columns
        phone_number = columns[ self.field_indexes[:phone_number] ] 
        self.skipped_rows += 1
        next if phone_number == '' or phone_number == nil
        c.phone_number = phone_number.gsub( /\D/, '')
        c.first_name =  columns[ self.field_indexes[:first_name] ]
        c.last_name =  columns[ self.field_indexes[:last_name] ] 
        c.source_id = columns[ self.field_indexes[:source_id] ]
        c.email = columns [ self.field_indexes[:email] ]
        c.source = source
        self.contacts.push(c)
      end

      reader.close
      return contacts
    end

    def fail(message)
      self.success = false
      self.result_message = message
    end

    def find_column_indexes(headers) 
      p headers
      headers.each_index do |index|
        header = headers[index]
        if ( self.field_names.has_value?(header) )
          key = self.field_names.index(header)
          field_indexes[key] = index
        end
      end

      ## make sure we found all of the columns
      self.field_indexes.each_pair do |key,value|
        if (value == -1)
          self.success = false
          self.result_message = "Did not find column header " + self.field_names[key] + " in first row of file."
          return false
        end
      end

      return self.success
    end
  end
end
end

