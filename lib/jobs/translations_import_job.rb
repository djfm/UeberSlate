class TranslationsImportJob
  @queue = "#{Rails.env}_translations_import_queue"
  
  def self.perform user_id, source_id, translations
    
    #RubyProf.start
    
    plog = Proglogger.new user_id
    
    user = User.find(user_id)
    user.notify "Started Translations Import Job!"
    
    language_ids    = {}
    get_language_id = lambda do |code|
      language_ids[code] = (Language.find_or_create_by_code code, :user_id => user_id).id unless language_ids[code]
      language_ids[code]
    end
    
    authorized_language_ids = User.find(user_id).authorized_to_translate_in
    
    plog.start_task "import translations", translations.count
    
    packs = Pack.all
    
    translations.each do |translation|
      
      plog.step
      
      language_id = get_language_id.call(translation['language_code'])
      
      
      if authorized_language_ids.empty? or authorized_language_ids.include?(language_id)
        t = Translation.find_or_initialize_by_key_and_language_id_and_string(
          translation['key'],
          language_id,
          translation['string'],
          :user_id => user_id,
          :reviewer_id => nil,
	  :source_id => source_id
        )
        
        id = t.id

        if translation['key'].length >= 255
          Rails.logger.debug "Achtung! Translation key too long!\n#{translation.inspect}."   
        elsif t.save
          if id
            puts "[#{id}] This is old news, not updating packs."
          else
            puts ">> New translation!"
            packs.each do |pack|
              pack.update_current_translation_with t, true
            end
          end
          #puts "Saved translation #{translation['string']}"
        else
          #puts "Oops for '#{t.inspect}:\n#{t.errors.full_messages.join("\n")}'"
        end
      else
        #puts "Not authorized to save translation in this language!"
      end
    end
    
    plog.end_task
    user.notify "Finished Translations Import Job!"
    
    #RubyProf::CallTreePrinter.new(RubyProf.stop).print(File.open(Rails.root + "log" + "import.profiler.grind", "w"))
    
  end
  
end
