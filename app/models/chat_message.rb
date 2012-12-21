class ChatMessage < ActiveRecord::Base
  attr_accessible :chat_id, :message, :user_id
  
  belongs_to :chat
  belongs_to :user
  
end
