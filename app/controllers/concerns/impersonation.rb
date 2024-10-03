module Impersonation
  extend ActiveSupport::Concern

  included do
    helper_method :impersonating?
  end

  private

    def resume_session
      Current.impersonated_user = find_impersonated_user
      super
    end

    def terminate_session
      super
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

