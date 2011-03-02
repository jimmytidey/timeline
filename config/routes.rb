Timeline::Application.routes.draw do
  get "users/cuke" if Rails.env.test?

  resources :users, :except => [:new, :edit]
  resources :timeline_charts, :except => [:show]
  resources :events

  match 'admin' => 'admin#index'

  get "home/index"
  get "home/new"

  #SIMILE Timeline requests & requires __history__.html files from various places.

  match '/:id/:name' => "timeline_charts#show", :as => 'view_chart'
  match '/:id' => "timeline_charts#show"
  match '/:id/:name/iframe' => "timeline_charts#iframe"
  
  root :to => "home#index"

  match ':action' => 'static#:action'


end
