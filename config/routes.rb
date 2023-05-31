Rails.application.routes.draw do
  devise_for :users
  # create a route for product result where the scraped data will be displayed
  get '/product/result', to: 'products#result'

  resources :products do
    resources :collection_items
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
end
