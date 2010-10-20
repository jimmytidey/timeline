class AdminController < ApplicationController
  before_filter :authenticate

  def authenticate
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      username == 'admin' && password == HTTP_BASIC_PASSWORD
    end
  end

end
