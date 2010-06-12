class WebMessage < Message

  validates_length_of :body, :minimum => 2, :maximum => 140

end
