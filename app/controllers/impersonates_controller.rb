class ImpersonatesController < ApplicationController
  # before_action :require_admin!

  def create
    impersonate User.find(params[:id])
    redirect_to root_url
  end

  def destroy
    stop_impersonating
    redirect_to root_url
  end

  private

  def require_admin!
    redirect_to root_path unless Current.user.admin?
  end
end
