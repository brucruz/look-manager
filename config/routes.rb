Rails.application.routes.draw do
  devise_for :users
  # create a route for product search where there will be a form get the url to be scraped
  get '/product/search', to: 'products#search'
  # create a route for product result where the scraped data will be displayed
  get '/product/result', to: 'products#result'

  resources :products do
    resources :product_images
    resources :product_sizes
    resources :user_product_categories
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
end
