class WebMessage < Message
  
  validates_presence_of :body
  validates_length_of :body, :maximum => 140

end
