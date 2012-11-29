# -*- encoding : utf-8 -*-
MAdeK::Application.routes.draw do

  wiki_root '/wiki'
  root :to => "application#root"

#####################################################

  # :action is actually more like a resources that describes part of MediaRsources, such as
  #   my_media_resources or my_sets_and_direct_descendants
  match 'visualization' => 'visualization#put', via: 'put'
  get 'visualization/filtered_resources' => 'visualization#filtered_resources'
  match 'visualization/:action(/:id)', controller: 'visualization'

  #match 'visualization/:action', controller: 'visualization'
  #match 'visualization/*params' => 'visualization#index', via: ['get']
  #match 'visualization/my_sets_and_direct_descendants' => 'visualization#my_sets_and_direct_descendants', via: ['get']

#####################################################

  match 'browse' => 'browse#index'
  match 'browse/:id' => 'browse#categories'
  match 'browse/:id/:category' => 'browse#sections'
  match 'browse/:id/:category/:section' => 'browse#media_resources'

###############################################

  # Mount the KSS engine for CSS styleguide development (development mode only)
  mount Nkss::Engine => '/styleguide' if Rails.env.development?

###############################################

  match '/help', :to => "application#help"
  match '/feedback', :to => "application#feedback"

  match '/login', :to => "authenticator/zhdk#login"
  match '/logout', :to => "authenticator/zhdk#logout"
  match '/db/login', :to => "authenticator/database_authentication#login"
  match '/db/logout', :to => "authenticator/database_authentication#logout"
  match '/authenticator/zhdk/login_successful/:id', :to => "authenticator/zhdk#login_successful"
  
###############################################

  match '/download', :controller => 'download', :action => 'download'
  
  match '/nagiosstat', :to => Nagiosstat


### media_resource_arcs ###############################
   
  match "/media_resource_arcs/:parent_id", controller: "media_resource_arcs", action: "get_arcs_by_parent_id", via: [:get]
  match "/media_resource_arcs/", controller: "media_resource_arcs", action: "get_arcs_by_parent_id", via: [:get]
  match "/media_resource_arcs/", controller: "media_resource_arcs", action: "update_arcs", via: [:put]

################################################

  resources :permissions, :only => :index, :format => true, :constraints => {:format => /json/} do
    collection do
      put :update # TODO merge to media_resources#update ??
    end
  end

  resources :permission_presets, :only => :index, :format => true, :constraints => {:format => /json/}

  resources :meta_context_groups, only: :index

  resources :keywords, only: :index
  resources :meta_terms, only: :index
  resources :meta_data, only: [:update] # TODO merge to media_resources#update ??
  resources :copyrights, only: :index


###############################################
#NOTE first media_entries and then media_sets

  # TODO merge to :media_resources ?? 
  resources :media_entries, :except => :destroy do
    collection do
      get :keywords
      post :edit_multiple
      put :update_multiple
      post :media_sets
      delete :media_sets
    end

    member do
      post :media_sets
      delete :media_sets
      get :image, :to => "media_resources#image"
      get :map
      get :browse
    end
    
    resources :meta_data do
      collection do
        get :edit_multiple
        put :update_multiple
      end
    end
  end
  
###############################################

  # TODO merge to :media_resources ?? 
  resources :media_sets, :except => :destroy do #-# TODO , :except => :index # the index is only used to create new sets
    collection do
      post :parents
      delete :parents
    end
    member do
      get :abstract
      get :browse
      get :inheritable_contexts
      post :settings
      post :parents # TODO: remove
      delete :parents # TODO: remove
      get :category
    end
    
    resources :meta_data do
      collection do
        get :edit_multiple
        put :update_multiple
      end
    end
    
    resources :media_entries, :except => :destroy do
      collection do
        delete :remove_multiple
      end
      member do
        delete :media_sets
      end
    end
  end
  
###############################################

#tmp#  constraints(:id => /\d+/) do
    
    resources :media_resources do
      collection do
        post :collection
        post :parents
        delete :parents
      end
      member do
        post :toggle_favorites
        get :image
      end

      resources :meta_data, only: [:update]
    end
    
#tmp#  end

###############################################

  resources :media_files # TODO remove ??
   
###############################################
# TODO refactor nested resources to people and make user as single resource

  resources :users do
    member do
      get :usage_terms
      post :usage_terms
    end
    collection do
      get :usage_terms
    end
    
    resources :media_sets, :except => [:index, :destroy] do # TODO remove
      member do
        post :add_member # TODO
      end
      collection do
        get :add_member
      end
      resources :media_entries, :except => :destroy
    end 
  end

  resources :people

  resources :groups, :only => [:index, :show, :create, :update, :destroy]

###############################################

  get  'import' => 'import#start'
  post 'import' => 'import#upload'
  delete 'import' => 'import#destroy'
  get  'import/dropbox' => 'import#dropbox'
  post 'import/dropbox' => 'import#dropbox'
  get  'import/permissions' => 'import#permissions', :as => "permissions_import"
  get  'import/meta_data' => 'import#meta_data', :as => "edit_import"
  get  'import/organize' => 'import#organize'
  put  'import/complete' => 'import#complete'
  
###################
   
  resource :session

  resources :meta_contexts, :only => :show do
    member do
      get :abstract
    end
  end

#__ Admin namespace __##############################################################
####################################################################################

  namespace :admin do
    match '/setup', :to => "setup#show"
    match '/setup/:action', :to => "setup"
  end

  ActiveAdmin.routes(self)
    
end
