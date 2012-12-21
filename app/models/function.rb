class Function < ActiveRecord::Base
  attr_accessible :role_id, :user_id, :language_id
  
  belongs_to :user
  belongs_to :role
  
  belongs_to :language
  
end
