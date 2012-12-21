class Grouping < ActiveRecord::Base
  attr_accessible :classification_id, :message_id
  
  belongs_to :classification
  belongs_to :message
  
  validates_presence_of :classification_id, :message_id
  validates_uniqueness_of :message_id, :scope => :classification_id
  
end
