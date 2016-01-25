Api::Application.routes.draw do
  namespace :api, constraints: { subdomain: 'api' }, path: '/', defaults: { format: 'json' } do
    resources :posts, except: [:new, :edit] do
      member do
        put :like
      end
      resources :comments, except: [:new, :edit] do
        member do
          put :like
        end
      end
    end

    root to: 'heartbeat#status'
  end
end
