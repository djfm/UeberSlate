class Language < ActiveRecord::Base
  attr_accessible :code, :locale, :name, :user_id
  
  validates_uniqueness_of :code
  validates_presence_of :code, :user_id
  
  def to_s
    "#{self.name}"
  end
  
end
