module API
  class ApplicationController < ActionController::Base
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::RoutingError, with: :render_not_found

    protect_from_forgery with: :null_session, if: proc { |c| c.request.format == 'application/json' }

    before_filter :authenticate, except: :render_not_found

    def render_unauthorized
      headers['WWW-Authenticate'] = 'Basic realm="Heartbeat"'

      respond_to do |format|
        format.json { render json: 'Bad credentials', status: 401 }
        format.xml { render xml: 'Bad credentials', status: 401 }
      end
    end

    def render_forbidden
      render json: 'Insufficient privileges', status: 403
    end

    def render_not_found
      render json: { error: 'Not Found' }.to_json, status: 404
    end

    protected

    def authenticate
      authenticate_basic_auth || render_unauthorized
    end

    def authenticate_basic_auth
      authenticate_with_http_basic do |username, password|
        @current_user = User.find_by_username!(username) if User.authenticate(username, password)
      end
    end
  end
end
