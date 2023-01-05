Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users

  root 'home#index'

  get 'home/index'
  get 'users/dashboard'
  get 'accounts', to: 'users#accounts'
  get 'wallets', to: 'users#wallets'

  patch 'verify/:payment_id', to: 'payments#verify', as: 'verify_payment'
  get '/payment_history', to: 'payments#history', as: 'payment_history'
  # post '/create_assurance_payment', to: 'payments#create_assurance_payment', as: 'create_assurance_payment'
  resources :pay_ins, only: [:create] do
    get :show_growth, on: :collection
  end
  resources :pay_outs, only: [:create]
  resources :users, only: [:index]
  namespace :support do
    resources :tickets, only: [:new, :create]
  end
end
