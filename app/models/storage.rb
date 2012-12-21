class Storage < ActiveRecord::Base
  attr_accessible :message_id, :pack_id, :storage_category, :storage_custom, :storage_method, :storage_path
  
  belongs_to :message
  
  validates_uniqueness_of :message_id, :scope => :pack_id
  
end
