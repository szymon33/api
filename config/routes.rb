Api::Application.routes.draw do
  get '/status', to: 'heartbeat#status'

  resources :posts, except: [:new, :edit] do
  	member do
  	  put :like
  	end
	resources :comments, except: [:new, :edit, :index] do
  	  member do
  	  put :like
  	end
  end

  end
  
  resources :users, except: [:new, :edit]

  root :to => 'heartbeat#status'
end
