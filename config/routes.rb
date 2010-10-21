Timeline::Application.routes.draw do
  resources :timeline_charts
  get "home/index"
  get "home/new"
  get "users/cuke" if Rails.env.test?

  resources :users
  root :to => "home#index"

end
