class Message < ActiveRecord::Base
  attr_accessible :key, :language_id, :string, :type, :user_id
  
  has_many :translations, :foreign_key => :key, :primary_key => :key
  has_many :current_translations
  
  has_many :actual_translations, :through => :current_translations, :source => :translation
  
  belongs_to :language
  
  validates_uniqueness_of :key
  validates_presence_of :string, :user_id, :language_id
  
  self.inheritance_column = nil
  
  def actual_translation pack_id, language_id
    actual_translations.where(:current_translations => {:pack_id => pack_id}, :language_id => language_id).first
  end
  
  def get_string pack_id, language_id
    if at = actual_translation(pack_id,language_id) then at.string else nil end or self.string
  end
  
end
