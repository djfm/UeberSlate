class Export < ActiveRecord::Base
  attr_accessible :language_id, :pack_id, :url
  
  belongs_to :pack
  belongs_to :language
  
  validates_uniqueness_of :language_id, :scope => :pack_id
  
end
