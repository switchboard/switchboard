Switchboard::Application.routes.draw do
  resources :gateways

  resources :service_phone_numbers

  resource :user_sessions

  match 'login' => "user_sessions#new", :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout

  resource :accounts
  resources :lists do
    resources :users
    resources :phone_numbers
    resources :messages
    member do
      get '/import' => 'lists#import'
      put '/upload_csv' => 'lists#upload_csv'
    end
    collection do
      get '/check_name_available' => 'lists#check_name_available'
    end
    match 'toggle_admin' => "lists#toggle_admin"
  end

  resources :messages
  match 'send_message/:list_id' => 'messages#send_message', via: :post, as: 'send_message'
  resources :users
  resources :phone_numbers, only: [:index]

  # non-resourceful controllers: Admin, daemon status
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
 
  # root :to => 'user_sessions#new'
  root to: 'lists#index'

end
