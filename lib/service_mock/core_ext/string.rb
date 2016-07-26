
class String
  def remove_newlines
    self.gsub("\n", "")
  end

  def escape_double_quotes
    self.gsub('"', "\\\"")
  end

  def remove_whitespace
    self.gsub("\n", "").gsub("\r", "").gsub("\t", "").gsub(" ", "")
  end
end