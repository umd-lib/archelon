Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'static_pages/about'

  resources :cas_users
  get '/cas_users/:id/history' => 'cas_users#show_history'

  get 'public_keys' => 'public_keys#index'

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

  get '/edit/:id', controller: 'resource', action: 'edit', constraints: { id: /.*/ }, as: 'resource_edit'
  post '/edit/:id', controller: 'resource', action: 'update', constraints: { id: /.*/ }

  post '/update/:id', controller: 'resource', action: 'update_state', constraints: { id: /.*/ }, as: 'update_resource'

  resources :bookmarks, constraints: { id: /.*/ } do
    concerns :exportable

    collection do
      delete 'clear'
      get 'export'
      get 'select_all_results'
      post 'toggle_multiple_selections'
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

  resources :import_jobs do
    collection do
      post ':id/import', to: 'import_jobs#import', as: 'perform_import'
    end
    member do
      post 'status_update', to: 'import_jobs#status_update', as: 'status_update'
    end
  end

  get 'login', to: redirect('/auth/cas'), as: 'login'
  get 'admin/user/login_as/:user_id', to: 'sessions#login_as', as: 'admin_user_login_as'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')

  get 'about' => 'static_pages#about'
  get 'help' => 'static_pages#help'

  get 'react_components' => 'react_components#react_components'
  post 'react_components' => 'react_components#react_components_submit'

  resources :publish_jobs, except: [:new] do
    member do
      post 'submit' => 'publish_jobs#submit'
      post 'status_update' => 'publish_jobs#status_update'
    end
  end
  get '/new_publish_job' => 'publish_jobs#new_publish_job'
  get '/new_unpublish_job' => 'publish_jobs#new_unpublish_job'

  get '/ping' => 'ping#verify'

  mount ActionCable.server, at: '/cable'
end
