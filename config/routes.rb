 Rails.application.routes.draw do
  #get 'order_screen/index'
  #get 'orderscreen/apples:int'
  #get 'orderscreen/oranges:int'
  #get 'orderscreen/bananas:int'
  #get 'orderscreen/peaches:int'
#  resources :order_screen do
#	collection {post :import }
  #end
  post "/import", to: "order_screen#import"
  post "/import_food_items", to: "order_screen#import_food_items"
  get "/order_screen", to: "order_screen#index"
  post "/order_screen", to: "order_screen#index"
  get "/faq", to: "order_screen#faq_screen"
  get '/order_screen:sort_by' => 'order_screen#index', :as => 'order_screen_search'
  post "/past_orders_aggregate", to: "order_screen#past_orders_aggregate"
  post "/past_orders_user", to: "order_screen#past_orders_user"
  get '/past_orders_aggregate/damage_report/:poaid', to: "order_screen#show_past_orders_aggregate_image"
  get '/past_orders_aggregate/explanation/:expid', to: "order_screen#show_past_orders_aggregate_explanation"
  get '/past_orders_user/damage_report/:poaid', to: "order_screen#show_past_orders_user_image"
  get '/past_orders_user/explanation/:expid', to: "order_screen#show_past_orders_user_explanation"
  get '/search:sort' => 'order_screen#index', :as => 'search_page'
  get "/newarrivals", to: "order_screen#newarrivals"
  get "/landing_screen", to: "order_screen#landing_screen"
  root 'order_screen#landing_screen'
  get '/modify', to: "order_screen#modify"
  get '/approve_users', to: "order_screen#approve_user"
  get '/cart', to: "order_screen#cart"
  get '/landing_screen_direct_order', to: "order_screen#landing_screen_direct_order"
  get '/landing_screen_fruit', to: "order_screen#landing_screen_fruit"
  get '/landing_screen_vegetable', to: "order_screen#landing_screen_vegetable"
  get '/landing_screen_other', to: "order_screen#landing_screen_other"
  get '/landing_screen_modify', to: "order_screen#landing_screen_modify"
  get '/past_orders_user', to: "order_screen#past_orders_user"
  get '/past_orders_aggregate', to: "order_screen#past_orders_aggregate"
  get '/search', to: "order_screen#search"
  get "/checkout", to: "order_screen#checkout"
  get "/export", to: "order_screen#export"
  get "/export_csv", to: "order_screen#export_csv"
  get "/test", to: "order_screen#test_screen"
  get "export_aggregate_csv", to: "order_screen#export_aggregate_csv"
  resources :users, only: [:new, :create]
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  get 'logout', to: 'sessions#logout'
  get '/welcome', to: 'sessions#index'
  get 'authorized', to: 'sessions#page_requires_login'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
