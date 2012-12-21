class Role < ActiveRecord::Base
  attr_accessible :name
  
  has_many :role_white_lists
  
  has_many :functions
  has_many :users, :through => :functions
  
  validates_uniqueness_of :name
  
end
