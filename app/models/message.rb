require 'csv'

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
  
  def self.dump
    CSV.open 'public/dump.csv', 'w' do |csv|
      csv << ["Email", "Message", "Key", "Language Code", "Translation"]
      Message.includes(:actual_translations).includes(:actual_translations => :language).each do |m|
        m.actual_translations.each do |t|
          if t.string and !t.string.strip.empty?
            csv << [t.user.email, m.string, m.key, t.language.code, t.string]
          end
        end
      end
    end
  end

end
