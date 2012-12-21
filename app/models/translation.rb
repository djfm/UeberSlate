class Translation < ActiveRecord::Base
  attr_accessible :language_id, :key, :reviewer_id, :string, :user_id, :source_id, :previous_translation_id
  
  belongs_to :source
  belongs_to :language
  belongs_to :user
  belongs_to :reviewer, :foreign_key => :reviewer_id, :primary_key => :user_id
  belongs_to :message, :foreign_key => :key, :primary_key => :key
  
  validates_presence_of :key, :user_id, :source_id, :string
  
  
  def better_than pack_id, translation
    return self.updated_at > translation.updated_at
  end
  
end
