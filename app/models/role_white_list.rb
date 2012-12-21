class RoleWhiteList < ActiveRecord::Base
  attr_accessible :action, :controller, :role_id, :any_language
  
  validates_presence_of :role_id, :action, :controller
  validates_uniqueness_of :role_id, :scope => [:action, :controller]
  
end
