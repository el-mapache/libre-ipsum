# Capitalize the first letter of a paragraph
class String
  def bicameralize 
    self.slice(0,1).capitalize << self.slice(1..-1) 
  end
end
