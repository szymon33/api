class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  before_filter :authenticate

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Basic realm="Heartbeat"'
    
    respond_to do |format|
      format.json { render json: 'Bad credentials', status: 401 }
      format.xml { render xml: 'Bad credentials', status: 401 }
    end
  end

  def current_user
    User.find(session[:user_id])
  end  
  
  protected
    def authenticate 
      authenticate_basic_auth || render_unauthorized
    end

    def authenticate_basic_auth
	    authenticate_with_http_basic do |username, password|
	      if User.authenticate(username, password)
          session[:user_id] = User.find_by_username!(username).id
          true
        end
	    end
  
    end
end
