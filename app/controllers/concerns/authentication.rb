module Authentication
  extend ActiveSupport::Concern

  # Routing constraints
  Authenticated = ->(request) { Current.session ||= Session.find_by(id: request.cookie_jar.signed[:session_id]) }
  Admin = ->(request) { Authenticated.call(request) && Current.user&.admin? }

  included do
    before_action :require_authentication
    helper_method :authenticated?
    helper_method :impersonating?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      before_action :resume_session
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end


    def resume_session
      Current.impersonated_user = find_impersonated_user
      Current.session = find_session_by_cookie
    end

    def find_session_by_cookie
      if (id = request.cookie_jar.signed[:session_id])
        Session.find_by(id: id)
      end
    end


    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_url
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end


    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
      stop_impersonating
    end


    def impersonating?
      Current.impersonated_user.present?
    end

    def impersonate(user)
      Current.impersonated_user = user
      session[:impersonated_user_id] = user.id
    end

    def find_impersonated_user
      if (id = session[:impersonated_user_id])
        User.find_by(id: id)
      end
    end

    def stop_impersonating
      Current.impersonated_user = nil
      session.delete(:impersonated_user_id)
    end
end
