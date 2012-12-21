module FayeHelper
  
  def broadcast(channel, data)
    message = {:channel => channel, :data => data}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
  
  def broadcast_to(channel, &block)
   broadcast channel, capture(&block)
  end
  
end