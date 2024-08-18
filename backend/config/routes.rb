Rails.application.routes.draw do
  root   "homes#top"
  get    "/signup"                 => "users#new"
  get    "/login"                  => "sessions#new"
  get    "/isLogin"                => "sessions#isLogin?"
  get    "/getRoomInfo"            => "matchs#getRoomInfo"
  get    "/games/:id/confirm"      => "games#confirm"
  get    "/games/:id/update_board" => "games#update_board"
  post   "/login"                  => "sessions#create"
  post   "/enterRoom"              => "matchs#enter_room"
  patch  "/makeRequest"            => "matchs#make_request"
  patch  "/acceptRequest"          => "matchs#accept_request"
  patch  "/declineRequest"         => "matchs#decline_request"
  patch  "/games/:id/updateBoard"  => "games#updateBoard"
  patch  "/games/:id/editBoard"    => "games#edit_board"
  patch  "/games/:id/update_time"  => "games#update_time"
  patch  "/games/:id/resign"       => "games#resign"
  delete "/logout"                 => "sessions#destroy"
  delete "/leaveRoom"              => "matchs#leave_room"
  resources :users
  resources :games
  resources :matchs
  
  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
