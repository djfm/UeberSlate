class PackBuildJob
  @queue = "#{Rails.env}_pack_build_queue"
  
  def self.perform user_id, pack_id, language_id
    
    user = User.find(user_id)
    user.notify "Started Pack Build Job!"
    
    Pack.find(pack_id).build_gzip language_id, user_id
    
    user.notify "Finished Pack Build Job!"
    
  end
  
end