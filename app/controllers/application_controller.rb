class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  http_basic_authenticate_with name: Figaro.env.http_basic_username,
                               password: Figaro.env.http_basic_password
end
