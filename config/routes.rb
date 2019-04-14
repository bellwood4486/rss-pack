Rails.application.routes.draw do
  root to: "home#index"

  devise_for :users

  resources :packs do
    resources :feeds, only: %i[index new create destroy]
  end
end
