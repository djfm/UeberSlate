# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  
  def new
    @languages = Language.all.map{|language| [language.name, language.id]}
    super
  end
  
  def create
    super
    if @user.id
      
    end
  end
end 