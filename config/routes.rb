Timeline::Application.routes.draw do
  get "users/cuke" if Rails.env.test?

  resources :users, :except => [:new, :edit]
  resources :timeline_charts
  resources :events

  match 'admin' => 'admin#index'

  get "home/index"
  get "home/new"

  #SIMILE Timeline requests & requires __history__.html files from various places.
  match '*__history__.html' => Proc.new { [200,{"Content-Type" => "text/html"},'<html><body>history</body></html>'] }

  match '/:id/:name/iframe' => "timeline_charts#iframe"
  
  root :to => "home#index"

  match ':action' => 'static#:action'


end
