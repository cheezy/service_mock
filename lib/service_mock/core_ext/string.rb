
class String
  def remove_newlines
    self.gsub("\n", "")
  end

  def escape_double_quotes
    self.gsub('"', "\\\"")
  end
end