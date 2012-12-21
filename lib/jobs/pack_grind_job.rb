class PackGrindJob
  @queue = "#{Rails.env}_pack_grind_queue"
  
  def self.perform user_id, pack_id, language_id
    
    user = User.find(user_id)
    user.notify "Started Pack Grind Job!"
    
    Pack.find(pack_id).grind language_id, user_id
    
    user.notify "Finished Pack Grind Job!"
    
  end
  
end