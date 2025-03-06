require 'karafka/web'

Rails.application.routes.draw do
  root "trains#index"
  post "train_movement", to: "trains#movement"

  mount Karafka::Web::App, at: '/karafka'
end

