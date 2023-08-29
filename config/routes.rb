require 'sidekiq/web'

Rails.application.routes.draw do
  mount Motor::Admin => '/motor_admin'
  mount Sidekiq::Web => "/sidekiq"
  mount GoodJob::Engine => 'good_job'

  resources :accounts, module: :accounts do
    resources :settings, only: [:index]
        resources :custom_attributes_definitions, module: :settings do

        end

        resources :webhooks, module: :settings do

        end
      # namespace :settings do
      #   get 'index' #, controller: "accounts/settings"
      #   resources :activity_kinds
      #   resources :whatsapp do
      #     post 'pair_qr_code', on: :collection
      #     post 'new_connection_status', on: :collection
      #     post 'disable'
      #   end
      # end
      resources :contacts do
        get 'search', to: 'contacts#search', on: :collection
        resources :notes, module: :contacts
        resources :events, module: :contacts do
        end
        namespace :events, module: :contacts do
          namespace :apps, module: :events do
            namespace :wpp_connects, module: :apps do
              resources :messages, module: :wpp_connects
            end
          end
        end

        collection do
          resources :chatwoot_embed, only: [:show, :new, :create], controller: 'contacts/chatwoot_embed' do
            post 'search', on: :collection
          end
        end
      end
      resources :pipelines do
        get 'import'
        post 'import_file'
        get 'export'
        get 'bulk_action'
        post 'create_bulk_action'
      end
      
      resources :deals do
        post 'create_whatsapp'
        get 'add_contact'
        post 'commit_add_contact'
        delete 'remove_contact'
        get 'new_select_contact', on: :collection
        resources :activities, module: :deals
        resources :flow_items, only: [:destroy], module: :deals
      end

      namespace :apps do
        resources :wpp_connects do
          get 'pair_qr_code'
          post 'new_connection_status'
          post 'disable'
        end

        resources :chatwoots
        #resources :events, module: :contacts
      end
  end
 
  devise_for :users
  root to: "accounts/pipelines#index"

  namespace :api do
    namespace :v1 do
      resources :accounts, module: :accounts do
        resources :deals, only: [:show, :create, :update] do
          post 'upsert', on: :collection
          resources :events, only: [:create], module: :deals do
          end
        end
        resources :contacts, only: [:show, :create]
        namespace :apps do
          resources :wpp_connects, only: [] do
            post 'webhook'
          end
          #resources :events, module: :contacts
        end
      end

      namespace :flow_items do
        resources :wp_connects do
          post 'webhook'
        end  
      end
      resources :contacts, only: [:create] do
        resources :wp_connects, only: [] do
          resources :messages, only: [:create], controller: "contacts/wp_connects/messages"
        end
      end
    end
  end

  namespace :embedded do
    resources :accounts, module: :accounts do
      namespace :apps do
        resources :chatwoots, only: [:index] do
        end
      end
    end
  end

  namespace :apps do
    resources :chatwoots do
      collection do
        post 'webhooks'
        get 'embedding'
        get 'embedding_init_authenticate'
        post 'embedding_authenticate'  
      end
    end
  end
end
