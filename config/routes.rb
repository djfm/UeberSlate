Ueberslate::Application.routes.draw do

  resources :chat_messages

  resources :chats do
    member do
      post '/', :action => 'post_message'
    end
  end

  resources :role_white_lists

  resources :functions

  resources :roles

  resources :module_packs do
    collection do
      post 'import_module'
    end
  end

  resources :exports

  resources :storages

  resources :translations do
    collection do
      post 'import'
    end
  end

  resources :sources

  resources :messages

  resources :languages

  resources :packs do
    member do
      get 'translate'
      post 'post_translation'
      post 'export'
      post 'grind'
    end
  end

  resources :projects do
    resources :packs
  end

  devise_for :users, :controllers => {:registrations => "registrations"}
  
  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
  end
  
  resources  :users


  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'
  
  mount Resque::Server, :at => "/resque"
  
  match '*a', :to => 'errors#routing'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
