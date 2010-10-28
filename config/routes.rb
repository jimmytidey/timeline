Timeline::Application.routes.draw do
  get "users/cuke" if Rails.env.test?

  resources :users
  resources :timeline_charts
  resources :events

  get "home/index"
  get "home/new"


  root :to => "home#index"

end
