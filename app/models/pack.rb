require 'util/proglogger.rb'
require 'ruby-prof'

class Pack < ActiveRecord::Base
  
  include StringsHelper
  
  attr_accessible :comment, :name, :project_id, :user_id, :is_current
  
  belongs_to :project
  
  has_many :classifications
  has_many :messages, :through => :classifications
  
  has_many :translations, :through => :messages
  
  has_many :current_translations
  
  has_many :storages
  has_many :exports
  has_many :statistics
  
  validates_presence_of :name, :user_id
  validates_uniqueness_of :name, :scope => [:project_id]
  

  def delete
    classifications.delete
    super
  end

  # Associate to this pack, and save messages
  #
  # The function takes in a user_id and a Hash of Hash of Array of Hash representing messages :)
  #
  # The first Hash has the Classification categories as key and hashes as values
  # The second Hash has the Group names as keys and arrays of hashes representing messages as values
  # 
  # Example: {"Front-Office" => {"SomeGroup" => [{'key' => 'blah4587','string' => 'Hello', 'language_code' => 'en', 'type' => 'some_type', 'storage' => STORAGE}]}}
  #           the 'type' key is optional   
  #
  # STORAGE is a hash containing storage info for the export of the pack, keys are: storage_method, storage_path, storage_category, storage_custom
  
  def save_messages user_id, category_group_messages
    
    plog = Proglogger.new user_id
    
    langs = {}
    
    count = 0
    category_group_messages.each_pair do |category, group_messages|
      group_messages.each_pair do |group, messages|
        count += messages.count
      end
    end
    
    plog.start_task "import messages", count
    
    category_group_messages.each_pair do |category, group_messages|
      group_messages.each_pair do |group, messages|
        messages.each do |message|
          plog.step
          code = message['language_code']
          language_id = langs[code]
          unless language_id
            language_id = (langs[code] = Language.find_or_create_by_code(code, :user_id => user_id).id)
          end
          
          if language_id
            #puts "[[ message type: '#{message['type']}']]"
            if (m = Message.find_or_create_by_key(message['key'], :language_id => language_id, :string => message['string'], :type => message['type'], :user_id => user_id)).errors.empty?
              if classifications.joins(:messages).where(:category => category, :group => group, :messages => {:id => m.id}).count == 0
                c = nil
                if group.empty?
                  c = classifications.create(:category => category, :group => group)
                else
                  c = classifications.find_or_create_by_category_and_group(category, group)
                end
                if c.errors.empty?
                  c.messages << m
                  #puts "Classified message #{m.inspect}"
                else
                  #puts "Could not create classification???\n#{c.errors.full_messages.join("\n")}"
                end
              else
                #puts "Message #{m} already associated to category '#{category}' and group '#{group}'"
              end
              
              #save storage info
              stored = storages.create(
                :message_id => m.id,
                :storage_method => message['storage']['storage_method'],
                :storage_path => message['storage']['storage_path'],
                :storage_category => message['storage']['storage_category'],
                :storage_custom => message['storage']['storage_custom']
              )
              
              unless stored.id
                #puts "Error storing storage info: \n#{stored.errors.full_messages.join("\n")}"
              end
              
            else
              #puts "Problem creating message #{m.inspect}:\n #{m.errors.full_messages.join("\n")}"
            end
          else
            #puts "Could not create language for '#{message['language_code']}'"
          end
        end
      end
    end
    
    plog.end_task
    
  end
  
  def update_current_translation_with candidate, in_loop=false
    
    unless @cached_message_ids or not in_loop
      @cached_message_ids = Set.new
      messages.select("messages.id").uniq.each do |m|
        @cached_message_ids << m.id
      end
    end
    
    unless candidate.message and if in_loop then @cached_message_ids.include? candidate.message.id else messages.find_by_id(candidate.message.id) end
      #puts "Translation #{candidate.id} with key #{candidate.key} has no message or is in the wrong pack, you know, I don't know!"
      return false
    end
 
    current_translation = current_translations.find_or_create_by_pack_id_and_message_id_and_language_id(self.id, candidate.message.id, candidate.language_id)
    
    #puts "    Current translation is: #{current_translation.inspect}"
    
    if current_translation.translation_id
      if candidate.better_than self.id, Translation.find(current_translation.translation_id)
        current_translation.translation_id = candidate.id
        if current_translation.save
          #puts "Used candidate as current translation because it's deemed better!"
        else
          #puts "Something wrong with current_translation #{current_translation}:\n#{current_translation.errors.full_messages.join("\n")}"
        end
      else
        #puts "Keeping current translation, the candidate was deemed of lesser quality."
      end 
    else
      current_translation.translation_id = candidate.id
      current_translation.save
      #puts "Used candidate as current translation because we had none."
    end
    
    #puts "Now current translation is: #{current_translation.inspect}"
    
  end
  
  def refresh_translations language_id, user_id = nil
    plog = Proglogger.new user_id
    trans = translations.find_all_by_language_id(language_id)
    plog.start_task "refresh_translations", trans.count
    trans.each do |translation|
      #puts "Refreshing (#{translation.id})"
      update_current_translation_with translation, true
      plog.step
    end
    plog.end_task
  end
  
  def build_gzip language_id, user_id = nil

    files = {}
    iso          = Language.find(language_id).code
    
    strgs = storages.includes(:message)
            .includes(:message => {:current_translations => :translation})
            .where(:current_translations => {:pack_id => [self.id, nil], :language_id => [language_id, nil]})
    
    plog = Proglogger.new user_id
    plog.start_task "export pack", strgs.count  
    
    strgs.each do |storage|
      storage_path = storage.storage_path.sub("[iso]",iso)
      if (ct = storage.message.current_translations.first) and (t = ct.translation)
        translation = if t then t.string else '' end
        if storage.storage_method == "ARRAY"
          unless files[storage_path]
            glob = "global #{storage.storage_custom};\n" unless storage_path == "/translations/#{iso}/tabs.php"
            files[storage_path] = "<?php\n\n#{glob}#{storage.storage_custom} = array();\n\n"
          end
          unless storage_path == "/translations/#{iso}/tabs.php" and (escape_quotes(translation).length >= 32)
            files[storage_path] += "#{storage.storage_custom}['#{escape_quotes(storage.message.key)}'] = '#{escape_quotes(translation).gsub(/\r\n|\n/,'\r\n')}';\n"
          end
        elsif storage.storage_method == "FILE"
          files[storage_path] = translation 
        end
      end
      plog.step
    end
    
    storages.find_all_by_storage_method("FILE").each do |storage|        
      storage_path = storage.storage_path.sub("[iso]",iso)
      unless files[storage_path]
	files[storage_path] = storage.message.key
      end
    end

    if files["/translations/#{iso}/tabs.php"]
      files["/translations/#{iso}/tabs.php"] += "\nreturn $_TABS;\n"
    end
    
    base_dir = "public/assets/export"
    
    project_string = project.name + "_" + project.version + "-" + name
    pack_dir = base_dir + "/" + project_string
    
    Dir.mkdir pack_dir unless File.directory? pack_dir
    
    dest = pack_dir + "/" + iso + ".gzip"
    
    plog.start_task "zipping"
    
    Archive.write_open_filename dest, Archive::COMPRESSION_GZIP, Archive::FORMAT_TAR do |ar|
      files.each_pair do |path, content|
        ar.new_entry do |entry|
          entry.pathname = path[1...path.length] #strip the leading slash
          entry.mode = 33212
          entry.size = content.bytesize
          entry.mtime = Time.now
          #puts entry.mtime
          ar.write_header entry
          ar.write_data content
          plog.step
        end
      end
    end
    plog.end_task
    
    export = exports.find_or_create_by_language_id(language_id)
    export.url = "/" + dest[/public\/(.*?)$/,1]
    export.save
    
  end
  
  def categories
    classifications.select('category').group('category').map{|c| c.category}
  end
  
  def compute_all_stats force_refresh=false
    stats = Hash.new do |h,k|
      h[k] = {}
    end
    
    language_ids_found = Set.new
    
    unless force_refresh
      Statistic.find_all_by_pack_id(self.id).each do |stat|
        language_ids_found << stat.language_id
        stats[stat.language_id][stat.category] = stat.percentize
      end
      
      language_ids_found.each do |id|
        total = Statistic.new :language_id => id, :category => '*', :total => 0, :translated => 0
        stats[id].each_pair do |c, s|
          total.total += s.total
          total.translated += s.translated
        end
        stats[id]['*'] = total.percentize
      end
    end
    
    missing = if language_ids_found.empty? then Language.all else Language.where("id not in (?)", language_ids_found) end
    missing.each do |language|
      stats[language.id] = compute_stats language.id, force_refresh
    end
    
    stats
  end
  
  def compute_stats language_id, force_refresh=false
    stats = {}
    
    total_name = "*"
    total = Statistic.new :pack_id => self.id, :total => 0, :translated => 0, :category => total_name
    
    categories.each do |category|
      
      s = statistics.find_or_create_by_language_id_and_category(language_id, category)
      
      if force_refresh or !s.total or !s.translated or (s.updated_at < 24.hours.ago) 
        Rails.logger.info "Recomputing stats for #{language_id} and category #{category}"
        s.total      = classifications.joins(:groupings).where(:category => category).count
        #s.translated = messages.joins(:current_translations).where(:classifications => {:category => category}, :current_translations => {:pack_id => self.id, :language_id => language_id}).count   
        s.translated = classifications.joins(:current_translations).where(:current_translations => {:pack_id => self.id, :language_id => language_id}, :classifications => {:category => category}).count
        s.updated_at = Time.now
        s.save
      end
      
      total.total      += s.total
      total.translated += s.translated
      
      stats[category] = s.percentize
      
    end
    
    stats[total_name] = total.percentize
    
    stats
  end
  
  def grind language_id, user_id=nil
    
    plog = Proglogger.new user_id
    
    #First update "current_translations" in case we have exact matches.
    #This Can happen if the pack is imported after the matching translations.
    plog.start_task "Refreshing translations"
    refresh_translations language_id, user_id
    
    #Now do serious stuff
    
    #find the translation in our language that are associated with a message
    trs = Translation.joins(:message).includes(:message).where(:translations => {:language_id => language_id})
    
    #construct a regular dictionary and a normalized dictionary
    regular    = Hash.new {|h,k| h[k] = []}
    normalized = Hash.new {|h,k| h[k] = []}
    
    plog.start_task "Building dictionaries", trs.count
    trs.each do |translation|
      message_string = translation.message.string
      normalized_message_string = normalize message_string
      
      regular[message_string]    << translation
      normalized[message_string] << translation
      plog.step
    end
    
    missing = displaced = approx = 0
    #loop through the pack's messages that don't have a translation
    
    msgs = messages.joins("LEFT OUTER JOIN translations ON translations.key = messages.key and translations.language_id = #{language_id.to_i}")
            .where(:translations => {:id => nil})
    
    plog.start_task "Autocompletion", msgs.count
             
    msgs.each do |message|
      missing += 1
      #puts "Message '#{message.string}' has no translation!"
      
      #see if we can complete it using the regular dictionary
      if not regular[message.string].empty?
        #puts "Filled with a displaced string!"
        displaced += 1
        regular[message.string].each do |candidate|
          candidate.message = message
          update_current_translation_with candidate, true
        end
      elsif not normalized[nrm = normalize(message.string)].empty?
        #puts "Filled with an approx string!"
        approx += 1
        normalized[nrm].each do |candidate|
          candidate.message = message
          update_current_translation_with candidate, true
        end
      end
      
      plog.step
      
    end
    
    plog.end_task
    plog.log "Missing: #{missing}, Displaced: #{displaced}, Approx: #{approx}"
    
    nil
    
  end
  
  def set_current
    Pack.transaction do
      Pack.update_all({:is_current => false}, true)
      self.is_current = true
      save
    end
  end
  
end
