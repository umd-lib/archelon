Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  get 'static_pages/about'

  resources :cas_users
  get '/cas_users/:id/history' => 'cas_users#show_history'

  mount Blacklight::Engine => '/'
  root to: 'catalog#index'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog', constraints: { id: /.*/ } do
    concerns :exportable
  end

  resources :bookmarks, constraints: { id: /.*/ } do
    concerns :exportable

    collection do
      delete 'clear'
      get 'export'
    end
  end

  resources :download_urls, only: %i[index show]
  get '/download_urls/generate/:document_url', controller: 'download_urls',
      action: 'generate_download_url', as: 'generate_download_url', constraints: { document_url: /.*/ }
  post '/download_urls/create', controller: 'download_urls',
       action: 'create_download_url', as: 'create_download_url'
  get '/download_urls/show/:token', controller: 'download_urls',
      action: 'show_download_url', as: 'show_download_url'
  put '/download_urls/disable/:token', controller: 'download_urls',
      action: 'disable', as: 'disable_download_url'

  get '/retrieve/:token', controller: 'retrieve', action: 'retrieve',
      as: 'retrieve'
  get '/retrieve/do/:token', controller: 'retrieve', action: 'do_retrieve',
      as: 'do_retrieve'

  resources :export_jobs

  get 'login', to: redirect('/auth/cas'), as: 'login'
  get 'admin/user/login_as/:user_id', to: 'sessions#login_as', as: 'admin_user_login_as'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  
  get 'about' => 'static_pages#about'
  get 'help' => 'static_pages#help'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
