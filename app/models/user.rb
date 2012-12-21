class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :last_seen, :channel, :last_translation_url
  # attr_accessible :title, :body
  
  validates_uniqueness_of :email
  
  has_many :functions
  has_many :roles, :through => :functions
  has_many :translations
  
  include FayeHelper
  
  def authorized_to controller, action, method, language_id
    puts "Authorizing #{self.email} for #{controller} #{action} #{language_id}..."
    return true if roles.find_by_name('admin')
    return false if method == :delete
    
    functions.includes(:role).each do |function|
      function.role.role_white_lists.find_all_by_controller_and_action(controller, action).each do |white_list|
        if white_list.any_language or (function.language_id.to_i == language_id.to_i and !function.language_id.nil?)
          puts "OK!"
          return true
        end
        puts "Any language? #{white_list.any_language ? "YES" : "NO, only #{function.language_id} but wanted #{language_id}"}"
      end
    end
    return false
  end
  
  def authorized_to_translate_in
    auth = []
    return auth if roles.find_by_name('admin')
    Language.all.each do |language|
      if authorized_to "packs", "post_translation", language.id
        auth << language.id
      end
    end
    return auth
  end
  
  def to_s
    self.email
  end
  
  def notify message, severity=:notice
    broadcast "/users/#{self.channel}/notifications/new", {:message => message, :severity => severity}
  end
  
  def channel
    
    unless read_attribute(:channel)
      write_attribute(:channel,SecureRandom.hex(32)) 
      save
    end
    
    read_attribute(:channel)
  end
  
  def delete
    functions.delete
    super
  end
  
  def translated_count
    translations.joins(:source).where(:sources => {:name => "USER"}).select(:key).uniq.count
  end
  
  def nick
    self.email.split('@').first
  end
  
end
