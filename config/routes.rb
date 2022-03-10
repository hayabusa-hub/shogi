Rails.application.routes.draw do
  root   "homes#top"
  get    "/signup"                 => "users#new"
  get    "/login"                  => "sessions#new"
  get    "/games/:id/confirm"      => "games#confirm"
  get    "/games/:id/update_board" => "games#update_board"
  post   "/login"                  => "sessions#create"
  patch  "/games/:id/editBoard"    => "games#edit_board"
  delete "/logout"                 => "sessions#destroy"
  resources :users
  resources :games
  resources :matchs
  
  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
