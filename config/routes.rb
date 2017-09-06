Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :feeds
  resources :users, only: %i(index new create destroy)
  resources :packs, only: %i(show)
  resources :rss, only: %i(show)
end
