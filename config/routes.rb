Rails.application.routes.draw do
  devise_for :users
  # create a route for product result where the scraped data will be displayed
  get '/product/result', to: 'products#result'

  get '/collection', to: 'collection_items#index'

  resources :products do
    resources :collection_items, except: [:index] do
    end
  end

  resources :stylist_clients

  # resources :collection_items, except: [:create, :index]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#index'
end
