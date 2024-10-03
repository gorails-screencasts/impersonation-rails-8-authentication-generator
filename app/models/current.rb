class Current < ActiveSupport::CurrentAttributes
  attribute :session
  # delegate :user, to: :session, allow_nil: true

  attribute :impersonated_user

  def user
    impersonated_user || true_user
  end

  def true_user
    session&.user
  end
end
