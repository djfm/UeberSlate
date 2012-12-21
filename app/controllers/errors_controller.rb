class ErrorsController < ApplicationController
  def routing
    
    if params[:a] =~ /{shop_logo}$/
      redirect_to "/assets/prestashop_logo.png"
    else
      render 'not_found'
    end
  end
  
end