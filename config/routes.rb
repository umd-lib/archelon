Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  root to: "catalog#index"
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
      get 'select_results'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # UMD Customization
  get 'about' => 'static_pages#about'
  get 'help' => 'static_pages#help'

  resources :cas_users
  get '/cas_users/:id/history' => 'cas_users#show_history'
  post '/cas_users/:id/active' => 'cas_users#active_state', as: 'cas_user_active_state'
  get 'public_keys' => 'public_keys#index'

  get 'login', to: redirect('/auth/cas'), as: 'login' unless CasHelper.use_developer_login
  get 'login', to: redirect('/auth/developer'), as: 'login' if CasHelper.use_developer_login
  get 'admin/user/login_as/:user_id', to: 'sessions#login_as', as: 'admin_user_login_as'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/:provider/callback', to: 'sessions#create'
  post 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')

  get 'react_components' => 'react_components#react_components'
  post 'react_components' => 'react_components#react_components_submit'

  # Metadata Edit endpoints
  get '/edit/:id', controller: 'resource', action: 'edit', constraints: { id: /.*/ }, as: 'resource_edit'
  post '/edit/:id', controller: 'resource', action: 'update', constraints: { id: /.*/ }
  post '/update/:id', controller: 'resource', action: 'update_state', constraints: { id: /.*/ }, as: 'update_resource'

  get '/ping' => 'ping#verify'

  # Export Jobs
  resources :export_jobs do
    collection do
      get 'review'
      get ':id/file', to: 'export_jobs#download', as: 'download'
      get ':id/binaries', to: 'export_jobs#download_binaries', as: 'download_binaries'
    end
    member do
      post 'status_update', to: 'export_jobs#status_update', as: 'status_update'
    end
  end

  # Import Jobs
  resources :import_jobs do
    collection do
      post ':id/import', to: 'import_jobs#import', as: 'perform_import'
    end
    member do
      post 'status_update', to: 'import_jobs#status_update', as: 'status_update'
    end
  end

  # Download URLs
  resources :download_urls

  # Retrieve using download URLs
  get '/retrieve/:token', controller: 'retrieve', action: 'retrieve',
      as: 'retrieve'
  get '/retrieve/do/:token', controller: 'retrieve', action: 'do_retrieve',
      as: 'do_retrieve'

  # Publish Jobs
  resources :publish_jobs, except: [:new] do
    member do
      post 'submit' => 'publish_jobs#submit'
      post 'status_update' => 'publish_jobs#status_update'
    end
  end
  get '/new_publish_job' => 'publish_jobs#new_publish_job'
  get '/new_unpublish_job' => 'publish_jobs#new_unpublish_job'

  # End UMD Customization

end
