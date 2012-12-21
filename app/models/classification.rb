class Classification < ActiveRecord::Base
  attr_accessible :category, :group, :pack_id, :grouping_id
  
  belongs_to :pack
  belongs_to :grouping
  
  has_many :groupings
  has_many :messages, :through => :groupings
  
  has_many :current_translations, :through => :messages
  
  validates_presence_of :pack_id, :category
  
  def delete
    groupings.delete
    super
  end
  
end
