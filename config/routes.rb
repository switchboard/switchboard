Switchboard::Application.routes.draw do
  resources :gateways
  resources :service_phone_numbers

  get  '/signin' => 'sessions#new',    as: :signin
  post '/signin' => 'sessions#create', as: :signin
  get '/signout' => 'sessions#destroy', as: :signout

  get '/auth/:provider/callback' => 'providers#create'
  get '/auth/failure' => 'providers#failure'
  resources :password_resets, except: [:show, :destroy]


  resources :lists do
    resources :contacts
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
  resources :contacts
  resources :phone_numbers, only: [:index]

  namespace :messages do
    post '/twilio/create' => 'twilio#create'
    post '/email/create' => 'email#create'
  end

  # non-resourceful controllers: Admin, daemon status
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
 
  # root :to => 'user_sessions#new'
  root to: 'lists#index'

end
