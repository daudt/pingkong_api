Rails.application.routes.draw do
  namespace :api do
    resources :matches, except: [:destroy, :update]
    resources :rankings, except: [:destroy, :create, :update]
    mount_devise_token_auth_for 'User', at: 'auth'
    resources :users
    get 'users/:uuid/approve', to: 'users#approve'
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  end
end
