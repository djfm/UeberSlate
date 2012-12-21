class Statistic < ActiveRecord::Base
  attr_accessible :category, :language_id, :pack_id, :total, :translated
  attr_accessor :percent_translated
  
  validates_presence_of :category
  validates_presence_of :pack_id
  validates_presence_of :language_id
  
  validates_uniqueness_of :category, :scope => [:pack_id, :language_id]
  
  def percentize
    self.percent_translated = (100.0*self.translated.to_f/self.total.to_f).round(1)
    self
  end
  
end
