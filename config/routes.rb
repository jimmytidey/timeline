Timeline::Application.routes.draw do
  get "users/cuke" if Rails.env.test?

  resources :users
  resources :timeline_charts
  resources :events

  get "home/index"
  get "home/new"

  #SIMILE Timeline requests & requires __history__.html files from various places.
  match '*__history__.html' => Proc.new { [200,{"Content-Type" => "text/html"},'<html><body>history</body></html>'] }

  root :to => "home#index"

end
