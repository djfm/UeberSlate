require 'adapters/messages_adapter.rb'
require 'adapters/translations_adapter.rb'
require 'jobs/translations_import_job.rb'

class ImportModuleJob
  @queue = "#{Rails.env}_import_module_queue"
  
  def self.perform user_id, archive_path
    
    user = User.find(user_id)
    user.notify "Started Module Import Job!"
    
    module_name = File.basename(archive_path,File.extname(archive_path)).downcase
    mp = ModulePack.find_or_create_by_module_name(module_name)
    project = Project.find_or_create_by_name("Modules", :version => "recent", :user_id => user_id)
    pack    = project.packs.find_or_create_by_name(module_name, :user_id => user_id)
    
    mp.project_id = project.id
    mp.pack_id = pack.id
    mp.archive_path = archive_path
    mp.save
    
    messages = MessagesAdapter.adapt_module_archive archive_path
    
    pack.save_messages user_id, messages
    
    translations = TranslationsAdapter.adapt_archive archive_path
    
    source = Source.find_or_create_by_name("MODULES")
    
    TranslationsImportJob.perform user_id, source.id, translations
    
    user.notify "Finished Module Import Job!"
    
  end
  
end