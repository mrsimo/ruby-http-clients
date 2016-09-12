Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/delay/:delay" => "home#index"
  root "home#index"
end
