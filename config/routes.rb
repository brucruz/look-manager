Rails.application.routes.draw do
  devise_for :users
  
  get '/product/result', to: 'products#result'

  get '/collection', to: 'collection_items#index'

  resources :products do
    resources :collection_items, except: [:index] do
    end
  end

  resources :stylist_clients

  root 'home#index'

  # Good Job dashboard
  authenticate :user, ->(user) { user.role === 'admin' } do
    mount GoodJob::Engine => 'good_job'
  end
end
