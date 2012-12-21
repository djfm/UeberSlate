class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  before_filter :check_permissions
  
  before_filter :_reload_libs, :if => :_reload_libs?
  before_filter :update_last_seen

  def _reload_libs
    RELOAD_LIBS.each do |lib|
      reloaded = require_dependency lib
      puts "Reloaded lib: #{lib} => #{reloaded}"
    end
  end
  
  def _reload_libs?
    defined? RELOAD_LIBS
  end
  
  def check_permissions
    
    puts "CNAME #{controller_name}"
    
    unless (controller_name == 'passwords') or (controller_name == 'home') or (controller_name == 'sessions') or (controller_name == 'registrations') or (controller_name == 'errors')
      
      if current_user and current_user.authorized_to(controller_name, action_name, request.method, params[:language_id])
          return
      end
      
      if current_user and request.xhr?
        current_user.notify "Access forbidden!", :error
      else
        flash[:error] = "You do not have access to this section!"
      end
      
      redirect_to :controller => :home, :action => :index
    end
  end
  
  def update_last_seen
    if current_user and (current_user.last_seen.nil? or current_user.last_seen < 5.minutes.ago)
      current_user.last_seen = DateTime.now
      current_user.save
    end
  end
  
end
