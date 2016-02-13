class WebMessage < Message

  validates_presence_of :body

  def from_web?
    true
  end
end
