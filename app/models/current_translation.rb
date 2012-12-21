class CurrentTranslation < ActiveRecord::Base
  attr_accessible :language_id, :message_id, :pack_id, :translation_id
  
  belongs_to :translation
  
  validates_uniqueness_of :message_id, :scope => [:pack_id, :language_id]

  def self.dedupe
	self.select("pack_id, language_id, message_id, max(id) as maxid, count(*) as num").group(:pack_id, :message_id, :language_id).having("count(*) > 1").each do |d| 
	CurrentTranslation.where(:pack_id => d.pack_id, :language_id => d.language_id, :message_id => d.message_id).where("id != #{d.maxid}").delete_all 
	end
  end
  
end
