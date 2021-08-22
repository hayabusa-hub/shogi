Rails.application.routes.draw do
  root   "homes#top"
  get    "/signup" => "users#new"
  get    "/login"  => "sessions#new"
  post   "/login"  => "sessions#create"
  delete "/logout" => "sessions#destroy"
  resources :users
  resources :games
  resources :matchs
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
