class MessagesImportJob
  @queue = "#{Rails.env}_messages_import_queue"
  
  def self.perform user_id, pack_id, messages
    
    user = User.find(user_id)
    user.notify("Started Messages Import Job!")
    
    Pack.find(pack_id).save_messages user_id, messages
    
    user.notify("Finished Messages Import Job!")
  end
  
end