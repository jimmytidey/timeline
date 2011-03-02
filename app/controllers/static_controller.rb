class StaticController < ApplicationController
  def about #'Add a new timeline' renders javascript to check if user is logged in.
    render 'about.html.erb'
  end
end