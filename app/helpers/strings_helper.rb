module StringsHelper
  
  def escape_quotes str
    str.gsub(/\\*'+/, '\\\\\'').gsub(/\\*"+/, '\\\\\"')
  end
  
  def normalize str
    str.downcase.gsub(/[,.:\s'"]+/,' ').gsub(/\s+/, ' ').strip
  end
  
end