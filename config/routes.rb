Rails.application.routes.draw do
  root   "homes#top"
  get    "/signup"               => "users#new"
  get    "/login"                => "sessions#new"
  post   "/login"                => "sessions#create"
  patch  "/games/:id/editBoard"  => "games#edit_board"
  patch  "/games/:id/putProcess" => "games#put_process"
  delete "/logout"               => "sessions#destroy"
  resources :users
  resources :games
  resources :matchs
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
