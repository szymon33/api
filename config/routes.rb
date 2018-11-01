Api::Application.routes.draw do
  namespace :api, constraints: { subdomain: 'api' }, path: '/', defaults: { format: 'json' } do
    namespace :v1 do
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

      match '*path', :to => 'application#render_not_found'
    end
  end
end
