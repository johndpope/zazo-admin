Rails.application.routes.draw do
  root 'dashboard#index'

  resources :users do
    member do
      get  :events
      get  :visualization
      get  :request_logs
      post :request_logs
    end
  end

  resources :connections

  resources :metrics, only: [:index, :show] do
    member do
      get :data
      post :options
    end
  end

  resources :messages, only: [:index, :show]

  get 'kvstore_admin' => 'kvstore_admin#index'
  get 'kvstore_admin/delete_all' => 'kvstore_admin#delete_all'
end
