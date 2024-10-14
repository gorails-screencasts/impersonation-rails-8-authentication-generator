class MainController < ApplicationController
  allow_unauthenticated_access only: [:about]

  def index
  end

  def admin
    render plain: "Admin area"
  end

  def dashboard
    render plain: "Dashboard"
  end

  def about
    render plain: "About"
  end
end
