Timeline::Application.routes.draw do

  #SIMILE Timeline requests & requires __history__.html files from various places.
  match '*__history__.html' => Proc.new { [200,{"Content-Type" => "text/html"},'<html><body>history</body></html>'] }

  get "users/cuke" if Rails.env.test?

  resources :users, :except => [:new, :edit]
  resources :timeline_charts
  resources :events

  resources :admins, :only => [:index, :update]

  get "home/new"

  match '/:id/:name/iframe' => "timeline_charts#iframe"
  
  match 'about' => 'static#about'
  match 'admin' => 'admins#index'
  root :to => "home#index"
end
