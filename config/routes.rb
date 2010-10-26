Timeline::Application.routes.draw do
  resources :users
  resources :timeline_charts
  resources :events

  get "home/index"
  get "home/new"

  get "users/cuke" if Rails.env.test?

  root :to => "home#index"

end
