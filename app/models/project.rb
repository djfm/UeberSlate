class Project < ActiveRecord::Base
  attr_accessible :comment, :name, :version, :user_id
  has_many :packs
  
  validates_presence_of :name, :version, :user_id
  validates_uniqueness_of :version, :scope => :name
  
  def delete
    packs.delete
    super
  end
  
  def to_s
    "#{name} (#{version})"
  end
  
end
