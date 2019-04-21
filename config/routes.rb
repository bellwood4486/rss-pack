Rails.application.routes.draw do
  root to: "home#index"

  devise_for :users

  resources :packs do
    resources :feeds, only: %i[new create destroy]
    resources :subscriptions, only: %i[index show create destroy]
  end

  get "rss/:token", to: "packs#rss", as: "pack_rss"
end
