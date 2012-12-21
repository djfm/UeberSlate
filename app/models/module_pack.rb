class ModulePack < ActiveRecord::Base
  attr_accessible :module_name, :pack_id, :project_id
  
  belongs_to :project
  belongs_to :pack
  
end
