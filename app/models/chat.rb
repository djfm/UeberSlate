class Chat < ActiveRecord::Base
  attr_accessible :name, :topic, :user_id
  
  validates_presence_of :name
  validates_presence_of :topic
  validates_presence_of :user_id
  
  has_many :chat_messages
  
end
