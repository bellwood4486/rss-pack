Rails.application.routes.draw do
  root to: "home#index"

  devise_for :users

  resources :packs do
    resources :feeds, only: %i[new create]
    resources :subscriptions, only: %i[show create destroy]
  end
  resources :feeds, only: %i[show destroy]

  get "rss/:token", to: "packs#rss", as: "pack_rss"
end
