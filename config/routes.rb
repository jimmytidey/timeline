Timeline::Application.routes.draw do
  get "users/cuke" if Rails.env.test?

  resources :users, :only => [:create, :destroy]
  resources :timeline_charts, :except => [:show]
  resources :events

  match 'admin' => 'admin#index'

  get "home/index"
  get "home/new"

  #SIMILE Timeline requests & requires __history__.html files from various places.
  match '*__history__.html' => Proc.new { [200,{"Content-Type" => "text/html"},'<html><body>history</body></html>'] }

  match '/:id/:name' => "timeline_charts#show"
  match '/:id' => "timeline_charts#show", :as => 'view_chart'

  root :to => "home#index"

end
