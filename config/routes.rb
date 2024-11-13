Rails.application.routes.draw do
  root "trains#index"
  post "train_movement", to: "trains#movement"
end
