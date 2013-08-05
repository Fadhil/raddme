Radd::Application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations"}

  resources :users, only: [:edit, :update, :show]
  match 'users/edit' => 'registrations#edit', as: :user_root
  
  resources :friendships, only: [:create]
  resources :contacts, only: [:index]
  match 'exchange/:token' => 'exchanges#show', as: :exchange

  match 'about' => 'home#about', as: :about
  get 'import' => 'users#import'
  post 'generate_users' => 'users#generate_users'
  match 'raddme.appcache' => 'offline#show'
  root :to => "home#index"

  match '*id' => 'users#show', as: :public_user
end
